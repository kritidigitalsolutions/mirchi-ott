// import 'dart:async';
// import 'package:flutter/material.dart';
//
// class LanguagePage extends StatefulWidget {
//   @override
//   _LanguagePageState createState() => _LanguagePageState();
// }
//
// class _LanguagePageState extends State<LanguagePage> {
//   String selectedLanguage = "All";
//
//   final List<String> imageList = [
//     "images/farzi.jpg",
//     "images/khaki.webp",
//     "images/kota_factory.jpg",
//     "images/taskaree.jpg",
//   ];
//
//   final List<String> languages = [
//     "Punjabi",
//     "Haryanvi",
//     "Bhojpuri",
//     "All",
//   ];
//
//   late ScrollController _scrollController;
//   Timer? _timer;
//
//   final double imageWidth = 120; // width to show 4 images properly
//
//   @override
//   void initState() {
//     super.initState();
//
//     _scrollController = ScrollController();
//
//     /// 🔥 Continuous Auto Scroll
//     _timer = Timer.periodic(Duration(milliseconds: 20), (timer) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(
//           _scrollController.offset + 1,
//         );
//
//         /// Infinite loop reset
//         if (_scrollController.offset >=
//             _scrollController.position.maxScrollExtent) {
//           _scrollController.jumpTo(0);
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//
//             /// 🔹 Top Bar
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//
//             /// 🔹 Continuous 4-Image Slider
//             Container(
//               height: 160,
//               child: ListView.builder(
//                 controller: _scrollController,
//                 scrollDirection: Axis.horizontal,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: imageList.length * 3,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     width: imageWidth,
//                     margin: EdgeInsets.symmetric(horizontal: 6),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.asset(
//                         imageList[index % imageList.length],
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//             SizedBox(height: 25),
//
//             /// 🔹 Title
//             Text(
//               "Personalize Your Experience",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             SizedBox(height: 8),
//
//             /// 🔹 Small Description
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Text(
//                 "Select your preferred content language to get better recommendations and discover amazing series.",
//                 style: TextStyle(
//                   color: Colors.white60,
//                   fontSize: 12,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//
//             SizedBox(height: 25),
//
//             /// 🔹 Select Language Text
//             Text(
//               "Select Content Language",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//
//             SizedBox(height: 10),
//
//             /// 🔹 Radio Buttons
//             Expanded(
//               child: ListView.builder(
//                 itemCount: languages.length,
//                 itemBuilder: (context, index) {
//                   return RadioListTile(
//                     activeColor: Colors.pinkAccent,
//                     value: languages[index],
//                     groupValue: selectedLanguage,
//                     title: Text(
//                       languages[index],
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedLanguage = value.toString();
//                       });
//                     },
//                   );
//                 },
//               ),
//             ),
//
//             /// 🔹 Save & Proceed Button
//             Padding(
//               padding: const EdgeInsets.all(15.0),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.pinkAccent,
//                   ),
//                   onPressed: () {
//                     print("Selected Language: $selectedLanguage");
//                   },
//                   child: Text(
//                     "Save & Proceed",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
