
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ChangeProfileImage extends StatelessWidget {
  const ChangeProfileImage({Key? key});


  Future<void> _uploadImage() async {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        final imageBytes = await pickedImage.readAsBytes();
        Uint8List compressImage(Uint8List imageBytes) {
          // Add your compression logic here
          // Example: Use image compression libraries like flutter_image_compress
          // to compress the imageBytes
          return imageBytes;
        }
        
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
        final databaseReference = FirebaseDatabase.instance.reference();
        print("joe mama");
        print(user!.uid);
        
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
      title: Text('Change Profile Image'),
      content: Text('Here you can change your profile image.'),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            // Add logic to save the new profile image
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Upload Image'),
          onPressed: _uploadImage,
        ),
      ],
    );
  }
}
        
       
