import 'package:flutter/material.dart';

import 'cast_crewPage.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final artist = artists[index];

                  return GestureDetector(
                    onTap: () {
                      print("Clicked on ${artist["name"]}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CastDetailsPage(
                            castName: artist["name"]!,
                            castImage: artist["image"]!,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 110,
                          width: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              image: AssetImage(artist["image"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
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
    );
  }
}
