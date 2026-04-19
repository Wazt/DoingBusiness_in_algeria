import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Video-based splash: plays the GT animated logo once, then routes via
/// AuthenticationRepository.screenRedirect() to Intro / Login / Main.
/// Tap anywhere on the video to skip early.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late VideoPlayerController _video;
  bool _routed = false;
  static const _maxDuration = Duration(seconds: 6);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));

    _video = VideoPlayerController.asset('assets/videos/gt_logo_animated.mp4')
      ..setLooping(false)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _video.play();
      }).catchError((_) {
        _route();
      });

    _video.addListener(_tick);
    Future.delayed(_maxDuration, _route);
  }

  void _tick() {
    if (!_video.value.isInitialized) return;
    if (_video.value.position >= _video.value.duration &&
        _video.value.duration > Duration.zero) {
      _route();
    }
  }

  void _route() {
    if (_routed || !mounted) return;
    _routed = true;
    AuthenticationRepository.instance.screenRedirect();
  }

  @override
  void dispose() {
    _video.removeListener(_tick);
    _video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _route,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: _video.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _video.value.aspectRatio,
                  child: VideoPlayer(_video),
                )
              : Image.asset(
                  'assets/images/logo_gt.png',
                  height: MediaQuery.of(context).size.width * 0.3,
                ),
        ),
      ),
    );
  }
}
