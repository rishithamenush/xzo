import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadGuidePhoto(File imageFile) async {
    try {
      // Ensure signed in
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      // Create a unique filename
      final fileName = 'guide_photos/${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      
      // Create a reference to the file location
      final storageRef = _storage.ref().child(fileName);
      
      // Upload the file
      final uploadTask = await storageRef.putFile(imageFile);
      
      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload guide photo: $e');
    }
  }
} 