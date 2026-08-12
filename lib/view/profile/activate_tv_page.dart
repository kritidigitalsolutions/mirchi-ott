// import 'package:flutter/material.dart';
//
// import '../../app/theme/app_colors.dart';
// import '../../widgets/qr_scanner.dart';
//
// class ActiveTvPage extends StatefulWidget {
//   const ActiveTvPage({super.key});
//
//   @override
//   State<ActiveTvPage> createState() => _ActiveTvPageState();
// }
//
// class _ActiveTvPageState extends State<ActiveTvPage> {
//   final List<TextEditingController> controllers =
//   List.generate(6, (index) => TextEditingController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Active TV",
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//
//             /// GIF IMAGE
//             Image.asset(
//               "images/asur2.jpeg",
//               height: 150,
//             ),
//
//             const SizedBox(height: 40),
//
//             /// TITLE
//             const Text(
//               "Activate Mirchi OTT on TV",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             /// SMALL TEXT
//             const Text(
//               "Enter the activation code shown on TV",
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 14,
//               ),
//               textAlign: TextAlign.center,
//             ),
//
//             const SizedBox(height: 20),
//
//             /// 6 DIGIT BOXES
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(6, (index) {
//                 return SizedBox(
//                   width: 45,
//                   child: TextField(
//                     controller: controllers[index],
//                     maxLength: 1,
//                     keyboardType: TextInputType.number,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.white, fontSize: 18),
//                     decoration: InputDecoration(
//                       counterText: "",
//                       filled: true,
//                       fillColor: Colors.grey[900],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onChanged: (value) {
//                       if (value.isNotEmpty) {
//                         // Move to next box
//                         if (index < 5) {
//                           FocusScope.of(context).nextFocus();
//                         }
//                       } else {
//                         // If backspace pressed, move to previous
//                         if (index > 0) {
//                           FocusScope.of(context).previousFocus();
//                         }
//                       }
//                     },
//                   ),
//                 );
//               }),
//             ),
//
//             const SizedBox(height: 25),
//
//             /// ACTIVATE BUTTON
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.buttonColor,
//                 ),
//                 onPressed: () {
//                   String code = controllers
//                       .map((controller) => controller.text)
//                       .join();
//                   print("Activation Code: $code");
//                 },
//                 child: const Text(
//                   "Activate Device",
//                   style: TextStyle(fontSize: 16,
//                   color: AppColors.white,
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 15),
//
//             const Text(
//               "OR",
//               style: TextStyle(color: Colors.white70),
//             ),
//
//             const SizedBox(height: 15),
//
//             /// SCAN QR BUTTON
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: OutlinedButton(
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: Colors.white),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const QrScannerPage(),
//                     ),
//                   );
//                 },
//                 child: const Text(
//                   "Scan QR Code",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 15),
//
//             const Text(
//               "Scan the QR code shown on TV",
//               style: TextStyle(
//                 color: Colors.white54,
//                 fontSize: 12,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
