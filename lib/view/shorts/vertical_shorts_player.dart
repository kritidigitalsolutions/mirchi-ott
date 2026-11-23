import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mirchi_ott/data/models/shorts_model.dart';
import 'package:mirchi_ott/view/auth/signInPage.dart';
import 'package:mirchi_ott/view/premium/goPremium.dart';
import 'package:mirchi_ott/view_model/auth_controller/auth_controller.dart';
import 'package:mirchi_ott/view_model/primium_controller/premium_controller.dart';

import '../../app/routes/app_routes.dart';

class VerticalShortsPlayer extends StatefulWidget {
  final List<ShortEpisode> episodes;
  final int initialIndex;
  final String dramaName;

  const VerticalShortsPlayer({
    super.key,
    required this.episodes,
    required this.initialIndex,
    required this.dramaName,
  });

  @override
  State<VerticalShortsPlayer> createState() => _VerticalShortsPlayerState();
}

class _VerticalShortsPlayerState extends State<VerticalShortsPlayer> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: widget.episodes.length,
        itemBuilder: (context, index) {
          return ShortVideoItem(
            episode: widget.episodes[index],
            dramaName: widget.dramaName,
            onEpisodesClick: () {
              Get.back();
            },
          );
        },
      ),
    );
  }
}

class ShortVideoItem extends StatefulWidget {
  final ShortEpisode episode;
  final String dramaName;
  final VoidCallback onEpisodesClick;

  const ShortVideoItem({
    super.key,
    required this.episode,
    required this.dramaName,
    required this.onEpisodesClick,
  });

  @override
  State<ShortVideoItem> createState() => _ShortVideoItemState();
}

class _ShortVideoItemState extends State<ShortVideoItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = true;

  final AuthController authController = Get.find<AuthController>();
  final PremiumController premiumController = Get.find<PremiumController>();

  bool get isLocked {
    final bool loggedIn = authController.isLoggedIn.value;
    if (!loggedIn) return true;

    final sub = premiumController.subscriptionData.value;
    final bool hasActivePlan = sub != null && sub['status'] == 'active';
    
    // Episode 1 is always unlocked for signed-in users
    if (widget.episode.episodeNumber == 1) return false;
    
    // Other episodes are locked if no active plan
    return !hasActivePlan;
  }

  @override
  void initState() {
    super.initState();
    if (!isLocked) {
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.episode.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _controller?.play();
            _controller?.setLooping(true);
          });
        }
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (isLocked) return;
    setState(() {
      if (_controller != null && _controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else if (_controller != null) {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isLocked)
            _buildLockedOverlay()
          else if (_isInitialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          
          /// Play/Pause Icon Overlay
          if (!isLocked && !_isPlaying)
            const Center(
              child: Icon(Icons.play_arrow, size: 80, color: Colors.white54),
            ),

          /// Right Side Options
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                _buildOption(Icons.favorite_border, "Like", (_) {}),
                const SizedBox(height: 20),
                _buildOption(Icons.share, "Share", (btnContext) {
                  final RenderBox? box = btnContext.findRenderObject() as RenderBox?;
                  final Rect? rect = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
                  Share.share(widget.episode.videoUrl, sharePositionOrigin: rect);
                }),
                const SizedBox(height: 20),
                _buildOption(Icons.playlist_play, "Episodes", (btnContext) => widget.onEpisodesClick()),
              ],
            ),
          ),

          /// Bottom Info
          Positioned(
            left: 16,
            bottom: 40,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.dramaName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.episode.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 12),
                /// Progress Indicator
                if (!isLocked && _isInitialized && _controller != null)
                  VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.red,
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.white10,
                    ),
                  ),
              ],
            ),
          ),
          
          /// Back Button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedOverlay() {
    final bool loggedIn = authController.isLoggedIn.value;
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, color: Colors.white, size: 80),
          const SizedBox(height: 20),
          Text(
            loggedIn
                ? (defaultTargetPlatform == TargetPlatform.iOS
                    ? "Manage your account to watch all episodes"
                    : "Subscribe to watch all episodes")
                : "Sign in to watch",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            onPressed: () {
              if (loggedIn) {
                if (Get.isRegistered<PremiumController>()) {
                  Get.find<PremiumController>().navigateToPremiumOrManageAccount(context);
                } else {
                  Get.put(PremiumController()).navigateToPremiumOrManageAccount(context);
                }
              } else {
                Get.toNamed(AppRoutes.signIn);
              }
            },
            child: Text(
              loggedIn
                  ? (defaultTargetPlatform == TargetPlatform.iOS ? "MANAGE ACCOUNT" : "GO PREMIUM")
                  : "SIGN IN",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String label, void Function(BuildContext) onTap) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () => onTap(context),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 35),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        );
      }
    );
  }
}
