import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/view_model/auth_controller/auth_controller.dart';
import 'package:mirchi_ott/view_model/content_controller/content_controller.dart';
import 'package:mirchi_ott/view_model/search_controller/search_controller.dart';

import '../../app/theme/app_colors.dart';
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../dramaDetails/cast_crewPage.dart';
import '../dramaDetails/dramaDetailsPage.dart';
import '../dramaDetails/topArtistpage.dart';
import '../popUp/search_with_mic.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  final List<Map<String, String>> cast = const [
    {'name': 'Shahid Kapoor', 'image': 'assets/images/Shahid_Kapoor.jpg'},
    {'name': 'Saru khan', 'image': 'assets/images/srk.jpeg'},
    {'name': 'Alia bhatta', 'image': 'assets/images/alia.jpeg'},
    {'name': 'Katarina', 'image': 'assets/images/katarina.jpeg'},
    {'name': 'Salman', 'image': 'assets/images/salman.jpeg'},
    {'name': 'Ranvir', 'image': 'assets/images/ranvir.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    final AppSearchController controller = Get.put(AppSearchController());
    final AuthController authController = Get.find<AuthController>();
    final ContentController contentController = Get.find<ContentController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// SEARCH BAR
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: (value) => controller.updateSearchQuery(value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search for movies, shows & more",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[900],
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() => controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white),
                                onPressed: controller.clearSearch,
                              )
                            : const SizedBox.shrink()),
                        IconButton(
                          icon: const Icon(Icons.mic, color: Colors.white),
                          onPressed: () async {
                            final result = await Get.to(() => const VoiceListeningPage());
                            if (result != null && result is String) {
                              controller.searchController.text = result;
                              controller.updateSearchQuery(result);
                            }
                          },
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              /// SEARCH RESULTS OR DEFAULT VIEW
              Obx(() {
                if (controller.searchQuery.value.isNotEmpty) {
                  return _buildSearchResults(controller, authController);
                } else {
                  return _buildDefaultSearchView(context, contentController, authController);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔍 SEARCH RESULTS VIEW
  Widget _buildSearchResults(AppSearchController controller, AuthController authController) {
    if (controller.searchResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Text(
            "No results found",
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.searchResults.length,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemBuilder: (context, index) {
        final item = controller.searchResults[index];
        return ListTile(
          onTap: () {
            Get.to(() => DramaDetailsPage(
                  isSignedIn: authController.isLoggedIn.value,
                  content: item,
                ));
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(
              item.poster,
              width: 50,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset("assets/images/farzi.jpg", width: 50, height: 70, fit: BoxFit.cover),
            ),
          ),
          title: Text(
            item.title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${item.releaseYear} • ${item.language}",
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        );
      },
    );
  }

  /// 🔥 DEFAULT VIEW (Top Series, Artists)
  Widget _buildDefaultSearchView(BuildContext context, ContentController contentController, AuthController authController) {
    // 1. Filter series and release items (not coming soon)
    final List<ContentModel> topSeries = contentController.allContent
        .where((item) => item.contentType == 'series' && item.isComingSoon == false)
        .toList();
    
    // 2. Sort by likes (descending)
    topSeries.sort((a, b) {
      int likesA = contentController.contentLikes[a.id] ?? 0;
      int likesB = contentController.contentLikes[b.id] ?? 0;
      return likesB.compareTo(likesA);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TOP SERIES
        if (topSeries.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "Top series",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: topSeries.length,
              itemBuilder: (context, index) {
                final item = topSeries[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      Get.to(() => DramaDetailsPage(
                            isSignedIn: authController.isLoggedIn.value,
                            content: item,
                          ));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        item.poster,
                        width: 170,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset("assets/images/farzi.jpg", width: 170, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 25),

        /// TOP ARTISTS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: InkWell(
            onTap: () {
              Get.to(() =>  TopArtistsPage());
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "Top Artists",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.to(() => CastDetailsPage(
                        castName: cast[index]['name']!,
                        castImage: cast[index]['image']!,
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage(cast[index]['image']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
