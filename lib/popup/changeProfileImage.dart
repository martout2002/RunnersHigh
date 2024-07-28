
// ignore_for_file: file_names

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ChangeProfileImage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const ChangeProfileImage({Key? key});


  Future<void> _uploadImage() async {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        final imageBytes = await pickedImage.readAsBytes();
        
        final compressedImageBytes = await FlutterImageCompress.compressWithList(
            imageBytes,
            minWidth: 600,
            minHeight: 800,
            quality: 88,
        );
        
        final encodedImageString = base64Encode(compressedImageBytes);

        // Store the encodedImageString in Firebase
        // ignore: deprecated_member_use
        final user = FirebaseAuth.instance.currentUser;
        // ignore: deprecated_member_use
        final databaseReference = FirebaseDatabase.instance.reference();
        
        await databaseReference.child('profiles').child(user!.uid).update({
          'profile_image': encodedImageString,
        });
        
      }
    }

    // Uint8List compressImage(Uint8List imageBytes) {
    //   // Add your compression logic here
    //   // Example: Use image compression libraries like flutter_image_compress
    //   // to compress the imageBytes
    //   return imageBytes;
      
    // }

  @override
  Widget build(BuildContext context) {

  

    return AlertDialog(
      title: const Text('Change Profile Image'),
      content: const Text('Here you can change your profile image.'),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            // Add logic to save the new profile image
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: _uploadImage,
          child: const Text('Upload Image'),
        ),
      ],
    );
  }
}
        
       
