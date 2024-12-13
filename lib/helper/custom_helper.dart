import 'dart:io';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_editor_demo/features/draggable_text_widget.dart';
import 'package:video_editor_demo/core/helper.dart';
import 'package:video_editor_demo/trimming_screen.dart';

/// @author: Sagar K.C.
/// @email: sagar.kc@fonepay.com
/// @created_at: 11/5/2024, Tuesday

class CustomHelper {
  static Future<String> cutVideo({
    required String videoPath,
    required double startingTime,
    required double endingTime,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      String segment1Path =
          "${directory.path}/segment1-${DateTime.now().minute}-${DateTime.now().second}.mp4";
      String segment2Path =
          "${directory.path}/segment2-${DateTime.now().minute}-${DateTime.now().second}.mp4";
      String outputPath =
          "${directory.path}/final_video_${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}.mp4";
      String segmentsListPath = "${directory.path}/segments.txt";

      // Enable verbose logging
      FFmpegKitConfig.enableLogCallback((log) {
        print("FFmpeg Log: ${log.getMessage()}");
      });

      // Cut the first segment (0 to startingTime)
      var session1 = await FFmpegKit.execute(
          '-i $videoPath -ss 0 -to $startingTime -c copy $segment1Path');
      if (!ReturnCode.isSuccess(await session1.getReturnCode())) {
        print(
            "Failed to create segment 1: ${await session1.getFailStackTrace()}");
        return '';
      }

      // Cut the second segment (endRemoveTime to the end of the video)
      var session2 = await FFmpegKit.execute(
          '-i $videoPath -ss $endingTime -c copy $segment2Path');
      if (!ReturnCode.isSuccess(await session2.getReturnCode())) {
        print(
            "Failed to create segment 2: ${await session2.getFailStackTrace()}");
        return '';
      }

      // Verify both segments were created
      if (!await File(segment1Path).exists()) {
        print("Error: segment1Path does not exist.");
        return '';
      }
      if (!await File(segment2Path).exists()) {
        print("Error: segment2Path does not exist.");
        return '';
      }

      // Create a text file with segment paths for the concat demuxer
      await File(segmentsListPath)
          .writeAsString("file '$segment1Path'\nfile '$segment2Path'\n");

      // Concatenate the segments to create the final video
      var concatSession = await FFmpegKit.execute(
          '-f concat -safe 0 -i $segmentsListPath -c copy $outputPath');

      var returnCode = await concatSession.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        print("Concatenation succeeded: $outputPath");
        // Clean up temporary files
        await File(segment1Path).delete();
        await File(segment2Path).delete();
        await File(segmentsListPath).delete();
        // await exportVideo(outputPath);

        return outputPath;
      } else {
        print(
            "Concatenation failed with error: ${await concatSession.getFailStackTrace()}");
        return '';
      }
    } catch (e) {
      print("Error during video processing: $e");
      return '';
    }
  }

  static Future<String> trimVideo({
    required String videoPath,
    required double startingTime,
    required double endingTime,
    required Duration videoLength,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      String outputPath =
          "${directory.path}/trimmed_video_${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}.mp4";

      double duration = endingTime - startingTime;
      var session = await FFmpegKit.execute(
          '-i $videoPath -ss $startingTime -t $duration -c copy $outputPath');

      var returnCode = await session.getReturnCode();
      print("result -->> ${returnCode?.isValueSuccess()}");
      print('Trimming Done: $outputPath');
      // await exportVideo(outputPath);
      return outputPath;
    } catch (e) {
      print("Error while trimming video: $e");
      return '';
    }
  }

  static Future<String> addText({
    required String videoPath,
    required WidgetRef ref,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      String outputPath =
          "${directory.path}/trimmed_video_${DateTime.now().hour}_${DateTime.now().minute}_${DateTime.now().second}.mp4";

      print("Output Path: $outputPath");

      // Enable verbose logging
      FFmpegKitConfig.enableLogCallback((log) {
        print("FFmpeg Log: ${log.getMessage()}");
      });

/*      final command = '''
  -i $videoPath -vf "drawtext=text='Your Text Here':fontcolor=white:fontsize=24:x=10:y=10" -codec:a copy -f mp4 $outputPath
''';*/

      var fontPath = '${getTemporaryDirectory()}/Roboto-Bold.ttf';
      final String text = ref.read(textProvider);
      final String textColor = ref.read(textColorProvider).colorName;
      final String backgroundColor =
          ref.read(backgroundColorProvider).colorName;
      final int horizontalPosition = ref.read(offsetProvider).dx.toInt();
      final int verticalPosition = ref.read(offsetProvider).dy.toInt();

      print(
          'hehehe : $fontPath -->> $text -->> $textColor -->> $backgroundColor');

      final command = "-y -i " +
          videoPath +
          " -vf \"drawtext=fontfile=" +
          fontPath +
          ":text='$text':fontcolor=$textColor:fontsize=48:box=1:boxcolor=$backgroundColor:boxborderw=40:x=$horizontalPosition:y=$verticalPosition\" -c:v libx264 -preset ultrafast -crf 28 -c:a copy " +
          outputPath;

      /* final command = "-y -i " +
          videoPath +
          " -filter_complex \"[0]drawtext=fontfile=" + fontPath + ":text=\'$text\':fontcolor=$textColor:fontsize=48:box=1:boxcolor=$backgroundColor:boxborderw=40:x=(w-text_w)/2:y=(h-text_h)/2\" -shortest -qscale 0 " +
          outputPath;*/

      /*  final command = "-y -i " +
          videoPath +
          " -filter_complex \"[0]drawtext=fontfile=" +
          fontPath +
          ":text=\'$text':fontcolor=$textColor:fontsize=24:box=1:boxcolor=$backgroundColor:boxborderw=5:x=(w-text_w)/2:y=(h-text_h)/2\" -shortest -qscale 0 " +
          outputPath;*/
      await FFmpegKit.execute(command).then((session) async {
        await session.getReturnCode().then((returnCode) {
          if (returnCode?.isValueSuccess() ?? false) {
            print("Text overlay added successfully");
          } else {
            print("Failed to add text overlay");
          }
        });
      });
      print('hehehe : end ');

      // await exportVideo(outputPath);

      return outputPath;
    } catch (e) {
      print("Error while adding text in the video: $e");
      return '';
    }
  }

  static Future<String> addTextNew({
    required String videoPath,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    try {
      // Create a temporary directory for the output
      final directory = await getTemporaryDirectory();
      String outputPath =
          "${directory.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4";

      // final int textHorizontalPosition = 12;
      // final int textVerticalPosition = 12;

      // FFmpeg command to overlay text
      var fontPath = '${directory.path}/Roboto-Bold.ttf';
      final String text = ref.read(textProvider);
      final String textColor = ref.read(textColorProvider).colorName;
      final String backgroundColor =
          ref.read(backgroundColorProvider).colorName;

      int horizontalPercentage = ref.read(horizontalPercentageProvider);
      int verticalPercentage = ref.read(verticalPercentageProvider);

      if (horizontalPercentage >= 50) {
        horizontalPercentage += 5;
      }
      if (verticalPercentage >= 50) {
        verticalPercentage += 3;
      }

      final command =
          "-y -i $videoPath -vf \"drawtext=fontfile=$fontPath:text='$text':fontcolor=$textColor:fontsize=70:box=1:boxcolor=$backgroundColor:boxborderw=28:x=(w*($horizontalPercentage/100)):y=(h*($verticalPercentage/100))\" -c:v libx264 -preset ultrafast -crf 28 -c:a copy $outputPath";

      // Execute the FFmpeg command
      await FFmpegKit.execute(command).then((session) async {
        await session.getReturnCode().then((returnCode) {
          if (returnCode?.isValueSuccess() ?? false) {
            print("Text overlay added successfully");
          } else {
            print("Failed to add text overlay");
          }
        });
      });

      return outputPath;
    } catch (e) {
      print("Error: $e");
      return '';
    }
  }

  static Future<void> saveVideo({
    required String editedVideoPath,
    required bool isAddToTextFeatureSelected,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    try {
      if (isAddToTextFeatureSelected &&
          ref.read(textProvider) != 'Default Text') {
        editedVideoPath = await addTextNew(
            videoPath: editedVideoPath, ref: ref, context: context);
        // editedVideoPath = await addText(videoPath: editedVideoPath, ref: ref);
      }

      // Get external storage directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception("Failed to get external storage directory.");
      }

      // Define the export directory
      String exportDir = "${directory.path}/final_video";
      final finalVideoDirectory = Directory(exportDir);

      // Check if the directory exists; if not, create it
      if (!await finalVideoDirectory.exists()) {
        await finalVideoDirectory.create(recursive: true);
      }

      // Generate a unique filename with a timestamp
      String timestamp =
          "${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}";
      String exportPath = "$exportDir/$timestamp.mp4";

      // Ensure the source file exists
      final File editedFile = File(editedVideoPath);
      if (!await editedFile.exists()) {
        throw Exception("Source file does not exist at path: $editedVideoPath");
      }

      // Copy the file to the target directory
      final File targetFile = File(exportPath);
      await editedFile.copy(exportPath);
      print("Video exported to: $exportPath");

      // Request access to save the video to the gallery
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      // Save the video to the gallery
      await Gal.putVideo(exportPath);
      print("Video saved to gallery successfully.");
    } catch (e) {
      throw 'Error is $e';
      print("Failed to export video: $e");
    }
  }

  static Future<void> registerApplicationFonts() async {
    var fontNameMapping = Map<String, String>();
    fontNameMapping["MyFontName"] = "Roboto-Bold";
    final directory = await getTemporaryDirectory();

    FFmpegKitConfig.setFontDirectoryList(
        [directory.path, "/system/fonts", "/System/Library/Fonts"],
        fontNameMapping);
    FFmpegKitConfig.setEnvironmentVariable(
        "FFREPORT",
        "file=" +
            new File(directory.path +
                    "/" +
                    DateTime.now().second.toString() +
                    "-ffreport.txt")
                .path);
  }
}
