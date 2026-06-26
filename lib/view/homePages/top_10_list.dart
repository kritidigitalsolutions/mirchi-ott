import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../utils/app_images.dart';
import '../../utils/responsive.dart';
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/catagory_widget.dart';
import '../../widgets/custom_network_image.dart';
import '../auth/signInPage.dart';
import '../dramaDetails/dramaDetailsPage.dart';

class Top10List extends StatelessWidget {
  final List<ContentModel> content;
  final bool isSignedIn;

  const Top10List({super.key, required this.content, required this.isSignedIn});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();
    bool isDesktop = Responsive.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 Trending on Mirchi TITLE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () {},
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Trending on Mirchi",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        /// 🔥 SLIDER
        SizedBox(
          height: isDesktop ? 340 : 180, // Increased to allow lift up
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: content.length > 10 ? 10 : content.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final item = content[index];
              return _Top10HoverCard(
                item: item, 
                index: index, 
                isSignedIn: isSignedIn, 
                isDesktop: isDesktop
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Top10HoverCard extends StatefulWidget {
  final ContentModel item;
  final int index;
  final bool isSignedIn;
  final bool isDesktop;

  const _Top10HoverCard({
    required this.item, 
    required this.index, 
    required this.isSignedIn, 
    required this.isDesktop
  });

  @override
  State<_Top10HoverCard> createState() => _Top10HoverCardState();
}

class _Top10HoverCardState extends State<_Top10HoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: widget.isDesktop ? 240 : 130, // Increased width
        margin: const EdgeInsets.only(right: 32), // Increased margin to prevent overlap
        transform: isHovered 
          ? (Matrix4.identity()..translate(0, -10, 0)..scale(1.05)) 
          : Matrix4.identity(),
        child: GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.dramaDetails, arguments: widget.item);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                bottom: widget.isDesktop ? -30 : -10,
                child: Text(
                  '${widget.index + 1}',
                  style: TextStyle(
                    fontSize: widget.isDesktop ? 260 : 150,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2
                      ..color = isHovered ? AppColors.primary : Colors.white.withOpacity(0.4),
                    shadows: isHovered ? [
                      Shadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 15)
                    ] : [],
                  ),
                ),
              ),

              /// Poster Image
              Positioned(
                left: widget.isDesktop ? 80 : 35, // Adjusted for spacing
                top: 10,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isHovered ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 3,
                        offset: const Offset(0, 10),
                      )
                    ] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: CustomNetworkImage(
                    imageUrl: widget.item.poster,
                    width: widget.isDesktop ? 150 : 95,
                    height: widget.isDesktop ? 230 : 140,
                    fit: BoxFit.fill,
                    borderRadius: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
