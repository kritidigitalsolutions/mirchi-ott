import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes/app_routes.dart';
import '../app/theme/app_colors.dart';
import '../utils/responsive.dart';
import '../data/models/response_model/content_response_model/content_model.dart';

import 'custom_network_image.dart';

class HomeSliderSection extends StatelessWidget {
  final String title;
  final List<ContentModel> content;
  final bool isSignedIn;

  const HomeSliderSection({
    super.key,
    required this.title,
    required this.content,
    required this.isSignedIn,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();
    bool isDesktop = Responsive.isDesktop(context);
    double screenWidth = MediaQuery.of(context).size.width;

    double mobileCardWidth = screenWidth > 600
        ? (screenWidth - 36) / 6.5
        : (screenWidth - 28) / 4.25;
    double posterHeight = mobileCardWidth / 0.70;
    double sliderHeight = isDesktop ? 340 : (posterHeight + 30);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 TITLE ROW WITH ACCENT BAR & VIEW ALL
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 14),
          child: Row(
            children: [
              Container(
                width: 3.5,
                height: isDesktop ? 22 : 18,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 22 : 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.categoryGrid,
                    arguments: {'title': title, 'content': content},
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View All",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: isDesktop ? 14 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.primary,
                        size: isDesktop ? 18 : 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        /// 🔥 SLIDER IMAGES
        SizedBox(
          height: sliderHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 14),
            itemCount: content.length,
            itemBuilder: (context, index) {
              final item = content[index];
              return _HoverCard(
                item: item,
                isSignedIn: isSignedIn,
                isDesktop: isDesktop,
                cardWidth: mobileCardWidth,
                posterHeight: posterHeight,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HoverCard extends StatefulWidget {
  final ContentModel item;
  final bool isSignedIn;
  final bool isDesktop;
  final double cardWidth;
  final double posterHeight;

  const _HoverCard({
    required this.item,
    required this.isSignedIn,
    required this.isDesktop,
    required this.cardWidth,
    required this.posterHeight,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isDesktop) {
      return _buildMobileCard(context);
    }
    return _buildDesktopCard(context);
  }

  Widget _buildMobileCard(BuildContext context) {
    return Container(
      width: widget.cardWidth,
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Get.toNamed(AppRoutes.dramaDetails, arguments: widget.item);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: widget.posterHeight,
              width: widget.cardWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CustomNetworkImage(
                imageUrl: widget.item.poster,
                fit: BoxFit.fill,
                borderRadius: 10,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: widget.cardWidth,
              child: Text(
                widget.item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopCard(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: isHovered ? 230 : 200,
        margin: const EdgeInsets.only(right: 32),
        transform: isHovered
            ? (Matrix4.identity()
                ..translate(0, -15, 0)
                ..scale(1.05))
            : Matrix4.identity(),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Get.toNamed(AppRoutes.dramaDetails, arguments: widget.item);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 25,
                        spreadRadius: 3,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomNetworkImage(
                  imageUrl: widget.item.poster,
                  fit: BoxFit.cover,
                  borderRadius: 15,
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isHovered ? 1.0 : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.item.releaseYear.toString(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
