import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirchi_ott/widgets/custom_network_image.dart';
import '../../data/models/response_model/content_response_model/content_model.dart';
import '../../utils/responsive.dart';
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
    bool isDesktop = Responsive.isDesktop(context);
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
      appBar: isDesktop ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Responsive.getBackIcon(context) ?? Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(castName, style: const TextStyle(color: Colors.white)),
      ) : null,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Stack(
            children: [
              /// 🔽 MAIN CONTENT
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      height: isDesktop ? 300 : height * 0.25,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: (castImage.isNotEmpty && castImage.startsWith('http'))
                          ? CustomNetworkImage(
                              imageUrl: castImage,
                              width: isDesktop ? 200 : 140,
                              height: isDesktop ? 200 : 140,
                              fit: BoxFit.cover,
                              borderRadius: 100,
                            )
                          : CircleAvatar(
                              radius: isDesktop ? 100 : 70,
                              backgroundImage: const AssetImage('assets/images/user.png'),
                            ),
                    ),

                    const SizedBox(height: 10),

                    /// 🔥 CAST NAME
                    if (!isDesktop) Center(
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 16),
                        child: const Text(
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
                        height: isDesktop ? 250 : 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: movies.length,
                          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 0),
                          itemBuilder: (context, index) {
                            final item = movies[index];

                            return GestureDetector(
                              onTap: () {
                                Get.to(() =>
                                    DramaDetailsPage(content: item,
                                      isSignedIn: authController.isLoggedIn.value,));
                              },
                              child: Container(
                                width: isDesktop ? 180 : 120,
                                margin: const EdgeInsets.only(left: 16),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: CustomNetworkImage(
                                        imageUrl: item.poster,
                                        fit: BoxFit.cover,
                                        borderRadius: 10,
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 16),
                        child: const Text(
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
                        height: isDesktop ? 250 : 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: series.length,
                          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 0),
                          itemBuilder: (context, index) {
                            final item = series[index];

                            return GestureDetector(
                              onTap: () {
                                Get.to(() =>
                                    DramaDetailsPage(content: item,
                                      isSignedIn: authController.isLoggedIn.value,));
                              },
                              child: Container(
                                width: isDesktop ? 180 : 120,
                                margin: const EdgeInsets.only(left: 16),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: CustomNetworkImage(
                                        imageUrl: item.poster,
                                        fit: BoxFit.cover,
                                        borderRadius: 10,
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

              /// 🔙 BACK BUTTON (Mobile only)
              if (!isDesktop) Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: Icon(Responsive.getBackIcon(context) ?? Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
