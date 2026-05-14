// import 'package:flutter/material.dart';
// import '../../app/theme/app_colors.dart';
// import '../premium/goPremium.dart';
// import 'create_profile_page.dart';
// import 'manage_profile.dart';
//
// class ProfileSelectionPage extends StatefulWidget {
//   const ProfileSelectionPage({super.key});
//
//   @override
//   State<ProfileSelectionPage> createState() =>
//       _ProfileSelectionPageState();
// }
//
// class _ProfileSelectionPageState
//     extends State<ProfileSelectionPage> {
//   String profileName = "Default";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//
//             const SizedBox(height: 70),
//
//             /// Logo
//             Center(
//               child: Image.asset(
//                 "assets/images/mirchi_logo.png",
//                 height: 80,
//               ),
//             ),
//
//             const SizedBox(height: 30),
//
//             const Text(
//               "Who's Watching?",
//               style: TextStyle(
//                 color: AppColors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//             const SizedBox(height: 40),
//
//             /// Profiles Row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//
//                 /// Default Profile
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => GoPremiumPage(),
//                       ),
//                     );
//                   },
//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundColor: Colors.grey,
//                         child: const Icon(Icons.person,
//                             size: 40, color: Colors.white),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         profileName,
//                         style: const TextStyle(
//                             color: AppColors.white),
//                       )
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(width: 40),
//
//                 /// Add Profile
//                 GestureDetector(
//                   onTap: () async {
//                     final result =
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) =>
//                         const CreateProfilePage(),
//                       ),
//                     );
//
//                     if (result != null) {
//                       setState(() {
//                         profileName = result;
//                       });
//                     }
//                   },
//                   child: Column(
//                     children: const [
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundColor: Colors.grey,
//                         child: Icon(Icons.add,
//                             size: 40, color: Colors.white),
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         "Add Profile",
//                         style: TextStyle(
//                             color: AppColors.white),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//
//             // const SizedBox(height: 40),
//
//             const Spacer(),
//             /// Manage Profiles Button
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context)=>ManageProfilesPage(profiles: [],
//                 )
//                 ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.buttonColor,
//               ),
//               child: const Text(
//                   "Manage Profiles",
//                 style: TextStyle(
//                   color: AppColors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
