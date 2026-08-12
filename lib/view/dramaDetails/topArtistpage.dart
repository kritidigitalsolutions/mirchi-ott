import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/app/routes/app_routes.dart';
import 'package:mirchi_ott/utils/responsive.dart';

class TopArtistsPage extends StatelessWidget {
  TopArtistsPage({super.key});

  final List<Map<String, String>> artists = [
    {"name": "Shahid Kapoor", "image": "assets/images/shahid_Kapoor.jpg"},
    {"name": "Shah Rukh Khan", "image": "assets/images/srk.jpeg"},
    {"name": "Deepika Padukone", "image": "assets/images/depika.jpeg"},
    {"name": "Salman Khan", "image": "assets/images/salman.jpeg"},
    {"name": "Alia Bhatt", "image": "assets/images/alia.jpeg"},
    {"name": "Ranveer Singh", "image": "assets/images/ranvir.jpg"},
    {"name": "Katrina Kaif", "image": "assets/images/katrina.jpeg"},
  ];

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isDesktop ? AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Responsive.backButton(context, onPressed: () => Get.back()),
        title: const Text("Top Artists", style: TextStyle(color: Colors.white)),
      ) : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                /// 🔹 Header (Mobile only)
                if (!isDesktop) Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    children: [
                      Responsive.backButton(context, onPressed: () => Get.back()),
                      const SizedBox(width: 10),
                      const Text(
                        "Top Artists",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔹 Grid Artists
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: artists.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 8 : 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final artist = artists[index];

                      return GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.castDetails, arguments: {
                            "name": artist["name"]!,
                            "image": artist["image"]!,
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 110,
                              width: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: AssetImage(artist["image"]!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (isDesktop) const SizedBox(height: 5),
                            if (isDesktop) Text(
                              artist["name"]!,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
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
