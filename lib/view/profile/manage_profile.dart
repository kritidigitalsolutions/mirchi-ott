// import 'package:flutter/material.dart';
// import 'package:mirchi_ott/data/models/profile_model.dart';
// import '../../app/theme/app_colors.dart';
// import 'create_profile_page.dart';
//
// class ManageProfilesPage extends StatefulWidget {
//   final List<Profile> profiles;
//
//   const ManageProfilesPage(
//       {super.key, required this.profiles});
//
//   @override
//   State<ManageProfilesPage> createState() =>
//       _ManageProfilesPageState();
// }
// class _ManageProfilesPageState
//     extends State<ManageProfilesPage> {
//
//   late List<Profile> profiles;
//
//   @override
//   void initState() {
//     profiles = List.from(widget.profiles);
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text("Manage Profiles",
//         style: TextStyle(color: AppColors.white),),
//         backgroundColor: AppColors.background,
//       ),
//       body: ListView.builder(
//         itemCount: profiles.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             leading: CircleAvatar(
//               backgroundImage:
//               AssetImage(profiles[index].avatar),
//             ),
//             title: Text(profiles[index].name,
//                 style:
//                 const TextStyle(color: Colors.white)),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//
//                 /// Edit
//                 IconButton(
//                   icon: const Icon(Icons.edit,
//                       color: Colors.white),
//                   onPressed: () async {
//                     final updated =
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) =>
//                           const CreateProfilePage()),
//                     );
//
//                     if (updated != null) {
//                       setState(() {
//                         profiles[index] = updated;
//                       });
//                     }
//                   },
//                 ),
//
//                 /// Delete
//                 IconButton(
//                   icon: const Icon(Icons.delete,
//                       color: Colors.red),
//                   onPressed: () {
//                     setState(() {
//                       profiles.removeAt(index);
//                     });
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.pop(context, profiles);
//         },
//         child: const Icon(Icons.check),
//       ),
//     );
//   }
// }
