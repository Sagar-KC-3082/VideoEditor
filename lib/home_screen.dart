/*
import 'dart:io';
import 'dart:math';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _videoPath;

  Future<void> _pickVideo() async {
    final XFile? pickedFile =
        await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _videoPath = pickedFile.path;
      });
      print("Picked video path: $_videoPath");
    } else {
      print("No video selected");
    }
  }

  Future<String> cutAndMergeVideo(String videoPath) async {
    final directory = await getTemporaryDirectory();
    print('hehhe  ${directory.path}');
    String segment1Path = "${directory.path}/segment1.mp4";
    String segment2Path = "${directory.path}/segment2.mp4";
    String outputPath = "${directory.path}/output_video.mp4";
    String concatFilePath = "${directory.path}/concat_list.txt";

    // Cut the first segment (0 to 10 seconds)
    await FFmpegKit.execute('-i $videoPath -ss 0 -to 10 -c copy $segment1Path');

    // Cut the second segment (15 seconds to end)
    await FFmpegKit.execute('-i $videoPath -ss 20 -c copy $segment2Path');

    // Create a text file for the concat demuxer
    await File(concatFilePath).writeAsString("file '$segment1Path'\nfile '$segment2Path'\n");

    // Combine the segments into the output file
    await FFmpegKit.execute(
        '-f concat -safe 0 -i $concatFilePath -c copy $outputPath'
    );

    // Clean up the temporary segment files and the concat file
    await File(segment1Path).delete();
    await File(segment2Path).delete();
    await File(concatFilePath).delete();

    return outputPath;
  }




  Future<void> exportVideo(String editedVideoPath) async {
    final directory = await getExternalStorageDirectory();
    String exportPath = "${directory!.path}/final_output_video.mp4";

    final File editedFile = File(editedVideoPath);
    await editedFile.copy(exportPath);

    print("Video exported to: $exportPath");


    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }


      await Gal.putVideo(editedFile.path);

    } catch (e) {
      print("Failed to scan file: $e");
    }
  }


  void processAndExportVideo(String videoPath) async {
    String editedVideoPath = await cutAndMergeVideo(videoPath);
    await exportVideo(editedVideoPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Editor")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickVideo,
              child: const Text("Pick Video from Gallery"),
            ),
            if (_videoPath != null)
              ElevatedButton(
                onPressed: () async {
                  processAndExportVideo(_videoPath!);
                },
                child: const Text("Edit Video"),
              ),
          ],
        ),
      ),
    );
  }
}
*/
