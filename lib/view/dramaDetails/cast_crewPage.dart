import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../../view_model/auth_controller/auth_controller.dart';
import '../../view_model/content_controller/content_controller.dart';
import 'dramaDetailsPage.dart';

class CastDetailsPage extends StatelessWidget {
  final String castName;
  final String castImage;

  const CastDetailsPage({
    super.key,
    required this.castName,
    required this.castImage,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    final contentController = Get.find<ContentController>();
    final AuthController authController = Get.find<AuthController>();

    /// 🎬 MOVIES FILTER
    final List<ContentModel> movies =
    contentController.allContent.where((item) {
      return item.contentType == "movie" &&
          item.cast != null &&
          item.cast!.any((c) => c.name == castName);
    }).toList();

    /// 📺 SERIES FILTER
    final List<ContentModel> series =
    contentController.allContent.where((item) {
      return item.contentType == "series" &&
          item.cast != null &&
          item.cast!.any((c) => c.name == castName);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 🔽 MAIN CONTENT
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔥 CAST IMAGE
                Container(
                  height: height * 0.25,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: (castImage.isNotEmpty &&
                        castImage.startsWith('http'))
                        ? NetworkImage(castImage)
                        : const AssetImage('assets/images/user.png')
                    as ImageProvider,
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔥 CAST NAME
                Center(
                  child: Text(
                    castName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// 🎬 MOVIES SECTION
                if (movies.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Movies",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final item = movies[index];

                        return GestureDetector(
                          onTap: () {
                            Get.to(() =>
                                DramaDetailsPage(content: item,
                                  isSignedIn: authController.isLoggedIn.value,));
                          },
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(left: 16),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    child: item.poster.isNotEmpty
                                        ? Image.network(
                                      item.poster,
                                      fit: BoxFit.cover,
                                    )
                                        : Container(
                                      color: Colors.grey,
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                      color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                /// 📺 SERIES SECTION
                if (series.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Series",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: series.length,
                      itemBuilder: (context, index) {
                        final item = series[index];

                        return GestureDetector(
                          onTap: () {
                            Get.to(() =>
                                DramaDetailsPage(content: item,
                                  isSignedIn: authController.isLoggedIn.value,));
                          },
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(left: 16),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    child: item.poster.isNotEmpty
                                        ? Image.network(
                                      item.poster,
                                      fit: BoxFit.cover,
                                    )
                                        : Container(
                                      color: Colors.grey,
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                      color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                /// ❌ EMPTY STATE
                if (movies.isEmpty && series.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No content found for this cast",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          ),

          /// 🔙 BACK BUTTON
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon:
              const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
