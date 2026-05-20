import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- Cloudinary configuration (replace with your values) ---
const String _cloudinaryCloudName = 'dsbfrianm';
const String _cloudinaryUploadPreset = 'todolist_preset';

// Lấy Google API key từ dotenv khi cần. Tránh đọc ở top-level
String? get googleApiKey {
  try {
    return dotenv.env['GOOGLE_API_KEY'];
  } catch (_) {
    // Nếu dotenv chưa được load, trả về null an toàn
    return null;
  }
}

/// AvatarService: pick image, upload to Cloudinary, optimize URL, save to Firestore.
class AvatarService {
  static final ImagePicker _picker = ImagePicker();

  /// Let user pick an image and upload it to Cloudinary.
  /// Returns the optimized image URL stored in Firestore, or null on cancel/error.
  static Future<String?> pickAndUploadAvatarToCloudinary(
    BuildContext context,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return null;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // compress client-side
        maxWidth: 1600,
      );
      if (image == null) return null;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đang tải ảnh lên...')));

      String? url;
      try {
        if (kIsWeb) {
          url = await _uploadFileToCloudinary(xfile: image);
        } else {
          url = await _uploadFileToCloudinary(file: File(image.path));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload thất bại: $e')));
        return null;
      }
      if (url == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Upload thất bại')));
        return null;
      }

      // Optimize URL: crop to face, square 200x200
      final optimized = url.replaceFirst(
        '/upload/',
        '/upload/c_thumb,w_200,h_200,g_face/',
      );

      // Write avatarUrl to `users` collection (single source of truth for avatar)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'avatarUrl': optimized,
      }, SetOptions(merge: true));

      // Remove avatarUrl from `register` if present (move rather than duplicate)
      try {
        await FirebaseFirestore.instance.collection('register').doc(uid).update(
          {'avatarUrl': FieldValue.delete()},
        );
      } catch (_) {
        // ignore if field doesn't exist or update fails
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật ảnh đại diện thành công')),
      );
      return optimized;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      return null;
    }
  }

  /// Upload local file to Cloudinary (unsigned preset). Returns secure_url or null.
  static Future<String?> _uploadFileToCloudinary({
    File? file,
    XFile? xfile,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload',
    );
    final req = http.MultipartRequest('POST', uri);
    req.fields['upload_preset'] = _cloudinaryUploadPreset;

    if (kIsWeb) {
      if (xfile == null) throw Exception('No XFile provided for web upload');
      final bytes = await xfile.readAsBytes();
      final multipart = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: xfile.name,
      );
      req.files.add(multipart);
    } else {
      if (file == null) throw Exception('No File provided for native upload');
      req.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      return data['secure_url'] as String?;
    }

    // Provide detailed error for easier debugging
    throw Exception(
      'Cloudinary upload failed (${resp.statusCode}): ${resp.body}',
    );
  }
}
