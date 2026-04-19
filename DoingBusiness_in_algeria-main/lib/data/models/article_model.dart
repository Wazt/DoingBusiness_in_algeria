import 'package:cloud_firestore/cloud_firestore.dart';

/// ════════════════════════════════════════════════════════════════════════
///  ArticleModel — extended for LinkedIn-source articles
/// ════════════════════════════════════════════════════════════════════════
///  New fields:
///    - source: 'editorial' (default, GT-authored) or 'linkedin' (mirrored)
///    - linkedinUrl: the original LinkedIn post URL (only set for source=linkedin)
///    - externalUrl: where "Open original" should navigate (typically same as linkedinUrl)
///    - author: extracted from og:author (optional, LinkedIn-source only)
///    - addedAt: server timestamp (when it was published in the app)
///    - addedBy: UID of the admin who published it
///
///  Backward compatible: articles without `source` are treated as 'editorial'.
/// ════════════════════════════════════════════════════════════════════════

enum ArticleSource { editorial, linkedin }

extension ArticleSourceX on ArticleSource {
  String get value => switch (this) {
        ArticleSource.editorial => 'editorial',
        ArticleSource.linkedin => 'linkedin',
      };

  static ArticleSource fromString(String? raw) {
    return switch (raw) {
      'linkedin' => ArticleSource.linkedin,
      _ => ArticleSource.editorial,
    };
  }
}

class ArticleModel {
  final String id;
  final String titre;
  final String blog;
  final String imageUrl;
  final String categoryId;
  final String pdfLink;

  /// New: source of this article
  final ArticleSource source;

  /// New: external URL (LinkedIn post URL). Null for editorial articles.
  final String? externalUrl;

  /// New: LinkedIn post URL specifically (redundant with externalUrl but
  /// kept for future sources like Twitter/Medium/etc)
  final String? linkedinUrl;

  /// New: author name (optional)
  final String? author;

  /// New: when the article was added to the feed
  final DateTime? addedAt;

  /// New: UID of the admin who added this article
  final String? addedBy;

  ArticleModel({
    required this.id,
    required this.titre,
    required this.blog,
    required this.imageUrl,
    required this.categoryId,
    required this.pdfLink,
    this.source = ArticleSource.editorial,
    this.externalUrl,
    this.linkedinUrl,
    this.author,
    this.addedAt,
    this.addedBy,
  });

  bool get isLinkedIn => source == ArticleSource.linkedin;

  static ArticleModel empty() => ArticleModel(
        id: '',
        titre: '',
        blog: '',
        imageUrl: '',
        categoryId: '',
        pdfLink: '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titre': titre,
        'blog': blog,
        'image': imageUrl,
        'categoryId': categoryId,
        'pdfLink': pdfLink,
        'source': source.value,
        if (externalUrl != null) 'externalUrl': externalUrl,
        if (linkedinUrl != null) 'linkedinUrl': linkedinUrl,
        if (author != null) 'author': author,
        if (addedAt != null) 'addedAt': Timestamp.fromDate(addedAt!),
        if (addedBy != null) 'addedBy': addedBy,
      };

  factory ArticleModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    if (data == null) return ArticleModel.empty();

    return ArticleModel(
      id: document.id,
      titre: data['titre'] as String? ?? '',
      blog: data['blog'] as String? ?? '',
      imageUrl: data['image'] as String? ?? '',
      categoryId: data['category'] as String? ?? '',
      pdfLink: data['pdfLink'] as String? ?? '',
      source: ArticleSourceX.fromString(data['source'] as String?),
      externalUrl: data['externalUrl'] as String?,
      linkedinUrl: data['linkedinUrl'] as String?,
      author: data['author'] as String?,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
      addedBy: data['addedBy'] as String?,
    );
  }
}
