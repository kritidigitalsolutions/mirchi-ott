import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_images.dart';
import '../utils/responsive.dart';
import '../data/models/response_model/content_response_model/content_model.dart';
import '../view/auth/signInPage.dart';
import '../view/dramaDetails/dramaDetailsPage.dart';
import 'custom_network_image.dart';
import 'catagory_widget.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 CLICKABLE TITLE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () {
              Get.to(() => CategoryGridPage(
                    title: title,
                    content: content,
                    isSignedIn: isSignedIn,
                  ));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        /// 🔥 SLIDER IMAGES
        SizedBox(
          height: isDesktop ? 340 : 220, // Increased height to allow for lift-up without clipping
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: content.length,
            itemBuilder: (context, index) {
              final item = content[index];
              return _HoverCard(item: item, isSignedIn: isSignedIn, isDesktop: isDesktop);
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

  const _HoverCard({required this.item, required this.isSignedIn, required this.isDesktop});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: widget.isDesktop ? (isHovered ? 230 : 200) : 150,
        margin: const EdgeInsets.only(right: 32), // More spacing to prevent overlap
        transform: isHovered 
          ? (Matrix4.identity()..translate(0, -15, 0)..scale(1.05)) 
          : Matrix4.identity(),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Get.to(() => DramaDetailsPage(
                  isSignedIn: widget.isSignedIn,
                  content: widget.item,
                ));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: isHovered ? [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 25,
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
            child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomNetworkImage(
                    imageUrl: widget.item.poster,
                    fit: BoxFit.fill,
                    borderRadius: 15,
                  ),
                  if (widget.isDesktop) AnimatedOpacity(
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
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                widget.item.releaseYear.toString(),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
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
