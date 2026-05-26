import 'package:flutter/material.dart';
import 'package:mirchi_ott/app/theme/app_colors.dart';

class ExpandablePlanCard extends StatefulWidget {
  final String title;
  final String price;
  final String duration;
  final List<String> features;
  final bool isHighlighted;
  final VoidCallback? onBuy;
  final VoidCallback? onSelect;

  const ExpandablePlanCard({
    Key? key,
    required this.title,
    required this.price,
    required this.duration,
    this.features = const [],
    this.isHighlighted = false,
    this.onBuy,
    this.onSelect,
  }) : super(key: key);

  @override
  State<ExpandablePlanCard> createState() => _ExpandablePlanCardState();
}

class _ExpandablePlanCardState extends State<ExpandablePlanCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: widget.isHighlighted
            ? Border.all(color: AppColors.buttonColor, width: 2)
            : Border.all(color: Colors.white12, width: 1),
        gradient: isExpanded
            ? LinearGradient(
          colors: [
            AppColors.buttonColor.withOpacity(0.8),
            Colors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isExpanded ? null : Colors.grey[900],
      ),
      child: Column(
        children: [

          /// 🔥 Top Section
          InkWell(
            onTap: () {
              if (widget.onSelect != null) widget.onSelect!();
              if (widget.onBuy != null) widget.onBuy!();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    children: [
                      Text(
                        "${widget.price}${widget.duration}",
                        style: const TextStyle(
                          color: AppColors.buttonColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      
                      /// 🔽 Arrow Button for Expansion ONLY
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                          if (widget.onSelect != null) widget.onSelect!();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white10,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),

          /// 🔥 Expanded Section
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 15),

                  /// Feature Row (Dynamic from API)
                  if (widget.features.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.features.isNotEmpty) featureBox(Icons.lock, widget.features[0]),
                      if (widget.features.length > 1) featureBox(Icons.block, widget.features[1]),
                      if (widget.features.length > 2) featureBox(Icons.sd, widget.features[2]),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// Bullet Points (Rest of features if any)
                  if (widget.features.length > 3)
                  Column(
                    children: List.generate(widget.features.length - 3, (index) {
                      return bulletText(widget.features[index + 3]);
                    }),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 🔹 Feature Icon Box
  Widget featureBox(IconData icon, String text) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }

  /// 🔹 Bullet Text
  Widget bulletText(String text,
      {MainAxisAlignment alignment = MainAxisAlignment.start}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
