import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CreateProfileController extends GetxController {
  var selectedImage = Rxn<File>();

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }
}
