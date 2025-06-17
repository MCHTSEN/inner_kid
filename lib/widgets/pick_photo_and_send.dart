import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inner_kid/features/first_analysis/components/native_dialogs.dart';

class ImageService {
  static Future<void> pickPhotoAndSend(
      {required BuildContext context, ImageSource? source}) async {
    ImagePicker imagePicker = ImagePicker();

    if (source == ImageSource.gallery) {
      XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // send image to server
      }
    } else if (source == ImageSource.camera) {
      XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        // send image to server
      }
    } else {
      NativeDialogs.showImagePickerActionSheet(
        context: context,
        onGalleryTap: () async {
          XFile? image =
              await imagePicker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            // send image to server
          }
        },
        onCameraTap: () async {
          XFile? image =
              await imagePicker.pickImage(source: ImageSource.camera);
          if (image != null) {
            // send image to server
          }
        },
      );
    }
  }
}
