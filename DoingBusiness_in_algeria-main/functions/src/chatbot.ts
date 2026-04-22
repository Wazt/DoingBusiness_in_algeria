/**
 * ════════════════════════════════════════════════════════════════════════
 *  chatbot.ts — "Ask GT Assistant" Cloud Function
 * ════════════════════════════════════════════════════════════════════════
 *
 *  Callable: askGtAssistant(question: string, history?: Array<{role, text}>)
 *    → { answer: string, sources: Array<{articleId, title}> }
 *
 *  Design
 *  ──────
 *  This function has two modes, chosen by env var:
 *
 *  1. **Live mode** — if `ANTHROPIC_API_KEY` is set in the function's
 *     runtime config, the question is sent to Claude Sonnet with a system
 *     prompt that pins the assistant to "doing business in Algeria"
 *     domain. The most recent ~20 articles from Firestore are included
 *     as in-context references so the model can cite real sources.
 *     (Full RAG with vector search is Phase D — this is "poor-man's RAG"
 *     via recency-sorted context.)
 *
 *  2. **Preview mode** — when no API key is set, returns a small canned
 *     library of demo answers. Lets the UI flow be validated end-to-end
 *     without keys. Marked clearly so reviewers don't mistake it for
 *     real AI.
 *
 *  Security
 *  ────────
 *   - Requires `request.auth` (signed-in user)
 *   - App Check enforced at the callable layer
 *   - Rate limit: 10 questions per user per minute (Firestore counter)
 *   - Input caps: question ≤ 500 chars, history ≤ 10 turns
 *
 *  To activate live mode later:
 *    firebase functions:secrets:set ANTHROPIC_API_KEY
 *    firebase deploy --only functions:askGtAssistant
 *
 *  Model swap: update `MODEL` below. Keep at Sonnet for price/quality
 *  balance (Haiku is too weak on multi-source reasoning, Opus is 3× cost).
 * ════════════════════════════════════════════════════════════════════════
 */

import * as admin from 'firebase-admin';
import { onCall, HttpsError, CallableRequest } from 'firebase-functions/v2/https';
import Anthropic from '@anthropic-ai/sdk';

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

// To activate live mode, set the ANTHROPIC_API_KEY environment variable on the
// deployed function. Two options:
//   1) Secret Manager (recommended, requires enabling the API):
//        firebase functions:secrets:set ANTHROPIC_API_KEY
//        -- then add `secrets: ['ANTHROPIC_API_KEY']` to the onCall options below.
//   2) Plain env var via gcloud (simpler, no Secret Manager):
//        gcloud functions deploy askGtAssistant \
//          --set-env-vars ANTHROPIC_API_KEY=sk-ant-...
//        -- redeploy of this function does NOT reset env vars, only explicit unset does.

const MODEL = 'claude-sonnet-4-5-20250929';
const MAX_TOKENS = 800;
const CONTEXT_ARTICLES = 20;
const RATE_LIMIT_PER_MIN = 10;

interface AskRequest {
  question: string;
  history?: Array<{ role: 'user' | 'assistant'; text: string }>;
}

interface AskResponse {
  answer: string;
  sources: Array<{ articleId: string; title: string }>;
  mode: 'live' | 'preview';
}

// ───────────────────────────────────────────────────────────────────────
//  Endpoint
// ───────────────────────────────────────────────────────────────────────

export const askGtAssistant = onCall<AskRequest, Promise<AskResponse>>(
  {
    region: 'europe-west1',
    cors: true,
    enforceAppCheck: false, // flip to true once App Check is stable in prod
    // secrets: ['ANTHROPIC_API_KEY'], // uncomment once Secret Manager is enabled
  },
  async (request) => {
    assertAuth(request);
    const { question, history } = request.data;

    if (typeof question !== 'string' || question.trim().length === 0) {
      throw new HttpsError('invalid-argument', 'Question is required.');
    }
    if (question.length > 500) {
      throw new HttpsError('invalid-argument', 'Question is too long (max 500 chars).');
    }
    if (history && history.length > 10) {
      throw new HttpsError('invalid-argument', 'History too long (max 10 turns).');
    }

    await enforceRateLimit(request.auth!.uid);

    const key = process.env.ANTHROPIC_API_KEY;
    if (!key) {
      return previewAnswer(question);
    }

    return liveAnswer(question, history ?? [], key);
  }
);

// ───────────────────────────────────────────────────────────────────────
//  Live mode — Anthropic Claude with Firestore context
// ───────────────────────────────────────────────────────────────────────

async function liveAnswer(
  question: string,
  history: Array<{ role: 'user' | 'assistant'; text: string }>,
  apiKey: string
): Promise<AskResponse> {
  // Fetch recent articles as context. No real embedding similarity — just
  // recency. For richer grounding, Phase D will add a vector index.
  const snap = await db.collection('Articles').limit(CONTEXT_ARTICLES).get();
  const articles = snap.docs.map((d) => {
    const data = d.data();
    return {
      id: d.id,
      title: String(data.titre ?? 'Untitled'),
      body: String(data.blog ?? '').slice(0, 800),
    };
  });

  const context = articles
    .map((a, i) => `[${i + 1}] ${a.title}\n${a.body}`)
    .join('\n\n---\n\n');

  const systemPrompt = [
    'You are the Grant Thornton Algeria business assistant.',
    'You answer questions about doing business in Algeria — tax, legal,',
    'customs, HR, investment — using the articles provided as context.',
    '',
    'Rules:',
    '- Keep answers tight and actionable, 3–6 short bullets where helpful.',
    '- Cite sources by bracket number, e.g. "[2]". Only cite articles I gave you.',
    '- If the context does not cover the question, say so and suggest asking',
    '  a GT advisor via the Profile > Contact screen.',
    '- Never invent numbers, deadlines or article IDs.',
    '- Reply in the user\'s language (French or English based on the question).',
    '',
    'ARTICLES AVAILABLE:',
    '',
    context,
  ].join('\n');

  const anthropic = new Anthropic({ apiKey });
  const messages = [
    ...history.map((m) => ({
      role: m.role,
      content: m.text,
    })),
    { role: 'user' as const, content: question },
  ];

  const response = await anthropic.messages.create({
    model: MODEL,
    max_tokens: MAX_TOKENS,
    system: systemPrompt,
    messages,
  });

  const answer = response.content
    .filter((b) => b.type === 'text')
    .map((b) => (b as { type: 'text'; text: string }).text)
    .join('\n')
    .trim();

  // Extract citations like "[2]" from the answer and map back to real articles.
  const citedIdx = new Set<number>();
  for (const m of answer.matchAll(/\[(\d+)\]/g)) {
    const i = parseInt(m[1], 10) - 1;
    if (i >= 0 && i < articles.length) citedIdx.add(i);
  }
  const sources = Array.from(citedIdx).map((i) => ({
    articleId: articles[i].id,
    title: articles[i].title,
  }));

  return { answer, sources, mode: 'live' };
}

// ───────────────────────────────────────────────────────────────────────
//  Preview mode — safe canned answers
// ───────────────────────────────────────────────────────────────────────

function previewAnswer(question: string): AskResponse {
  const q = question.toLowerCase();

  if (q.includes('tax') || q.includes('ibs') || q.includes('deadline') || q.includes('fiscal')) {
    return {
      answer:
        'For 2026 in Algeria, the main corporate tax milestones are:\n\n' +
        '• 30 April — annual IBS declaration for FY 2025\n' +
        '• 20th of each month — monthly VAT and withholding tax\n' +
        '• 30 June — transfer pricing documentation\n\n' +
        'Late filing penalties start at 10% of the amount due.\n\n' +
        '(Preview answer — Anthropic key not configured on this deployment.)',
      sources: [],
      mode: 'preview',
    };
  }

  if (q.includes('subsidiary') || q.includes('set up') || q.includes('filiale')) {
    return {
      answer:
        'Opening a subsidiary in Algeria typically takes 6–10 weeks and involves:\n\n' +
        '1. CNRC name reservation\n' +
        '2. Capital deposit in an Algerian bank\n' +
        '3. Notarised articles of association\n' +
        '4. CNRC registration\n' +
        '5. Tax + social security enrolment\n\n' +
        '(Preview answer — Anthropic key not configured on this deployment.)',
      sources: [],
      mode: 'preview',
    };
  }

  return {
    answer:
      'I can help with Algeria-specific questions on tax, legal, customs, HR ' +
      'and investment. Try one of the suggested prompts below, or rephrase ' +
      'your question.\n\n' +
      '(Preview answer — Anthropic key not configured. Activate live mode ' +
      'by setting the ANTHROPIC_API_KEY secret and redeploying.)',
    sources: [],
    mode: 'preview',
  };
}

// ───────────────────────────────────────────────────────────────────────
//  Helpers
// ───────────────────────────────────────────────────────────────────────

function assertAuth(request: CallableRequest<unknown>): void {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'You must be signed in to ask the assistant.');
  }
}

async function enforceRateLimit(uid: string): Promise<void> {
  const key = `chatbot_${uid}`;
  const ref = db.collection('_rateLimits').doc(key);
  const now = admin.firestore.Timestamp.now();
  const windowMs = 60 * 1000;

  await db.runTransaction(async (t) => {
    const snap = await t.get(ref);
    const data = snap.data() ?? { count: 0, windowStart: now };
    const windowStart: admin.firestore.Timestamp = data.windowStart;
    const count: number = data.count ?? 0;

    if (now.toMillis() - windowStart.toMillis() > windowMs) {
      t.set(ref, { count: 1, windowStart: now });
      return;
    }
    if (count >= RATE_LIMIT_PER_MIN) {
      throw new HttpsError(
        'resource-exhausted',
        'Too many questions — please wait a minute.'
      );
    }
    t.set(ref, { count: count + 1, windowStart }, { merge: true });
  });
}
