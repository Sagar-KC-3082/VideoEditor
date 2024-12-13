import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_editor_demo/helper/custom_helper.dart';
import 'package:video_editor_demo/trimming_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestStoragePermissions();
  await CustomHelper.registerApplicationFonts();
  runApp(const ProviderScope(
    child: MaterialApp(
      home: TrimmingScreen(),
    ),
  ));
}

Future<bool> requestStoragePermissions() async {
  final status = await Permission.storage.request();
  if (status.isGranted) {
    return true;
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
  return false;
}
