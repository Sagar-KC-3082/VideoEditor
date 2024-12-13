import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_editor_demo/core/context_extension.dart';
import 'package:video_editor_demo/core/custom_button.dart';
import 'package:video_editor_demo/features/draggable_text_widget.dart';
import 'package:video_editor_demo/helper/custom_helper.dart';

import 'core/custom_enums.dart';

final isTrimmingProvider = StateProvider((ref) => false);
final isCuttingProvider = StateProvider((ref) => false);
final isSavingProvider = StateProvider((ref) => false);

final horizontalPercentageProvider = StateProvider<int>((ref) => 0);
final verticalPercentageProvider = StateProvider<int>((ref) => 0);

class TrimmingScreen extends ConsumerStatefulWidget {
  const TrimmingScreen({super.key});

  @override
  ConsumerState<TrimmingScreen> createState() => _TrimmingScreenState();
}

class _TrimmingScreenState extends ConsumerState<TrimmingScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _videoPath;
  late VideoEditorController _controller;
  final GlobalKey _stackKey = GlobalKey();

  bool isInitialised = false;
  bool _showTextSection = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_videoPath != null && _controller.initialized)
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: Stack(
                          key: _stackKey,
                          children: [
                            CropGridViewer.preview(
                              controller: _controller,
                            ),
                            if (_showTextSection) const DraggableTextWidget(),
                          ],
                        ),
                      ),
                    ),
                    _playPauseIcon(),
                    _trimSlider(),
                    const SizedBox(height: 8),
                    _functionalityRow(),
                  ],
                ),
              ),
            _uploadVideo(),
          ],
        ),
      ),
    );
  }

  Padding _functionalityRow() {
    final isTrimmingState = ref.watch(isTrimmingProvider);
    final isCuttingState = ref.watch(isCuttingProvider);
    final isSavingState = ref.watch(isSavingProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _functionalityButton(
            label: 'Trim',
            color: Colors.green,
            icon: Icons.crop,
            isLoading: isTrimmingState,
            onTap: () async {
              await _trimVideo();
            },
          ),
          _functionalityButton(
            label: 'Cut',
            color: Colors.blue,
            icon: Icons.content_cut,
            isLoading: isCuttingState,
            onTap: () async {
              await _cutVideo();
            },
          ),
          _functionalityButton(
            label: 'Text',
            color: Colors.pink,
            icon: Icons.text_fields,
            onTap: () async {
              setState(() {
                _showTextSection = !_showTextSection;
              });
            },
          ),
          _functionalityButton(
            label: 'Save',
            isLoading: isSavingState,
            color: Colors.orange,
            icon: Icons.save_alt,
            onTap: () async {
              if (_showTextSection) {
                  final RenderBox renderBox =
                      _stackKey.currentContext?.findRenderObject() as RenderBox;
                  final Offset position = renderBox.localToGlobal(Offset.zero);
                  final double height = renderBox.size.height + position.dy;
                  final double width = renderBox.size.width + position.dx;

                  print('Stack height : $height');
                  print('Stack width: $width');

                  print('Stack width dx: ${position.dx}');
                  print('Stack width: ${renderBox.size.width}');

                  final containerHeight = ref.read(offsetProvider).dy;
                  final containerWidth = ref.read(offsetProvider).dx;
                  print('Container startPosition height: $containerHeight');
                  print('Container startPosition width: $containerWidth');

                  ref.read(horizontalPercentageProvider.notifier).state =
                      ((containerWidth / width) * 100).toInt();
                  ref.read(verticalPercentageProvider.notifier).state =
                      ((containerHeight / height) * 100).toInt();

                  print(
                      'final horizontal percentage : ${ref.read(horizontalPercentageProvider.notifier).state}');
                  print(
                      'final vertical percentage : ${ref.read(verticalPercentageProvider.notifier).state}');
              }

              await _saveVideo();
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Future<void> _saveVideo() async {
    ref.read(isSavingProvider.notifier).state = true;
    try {
      await CustomHelper.saveVideo(
        editedVideoPath: _videoPath ?? '',
        isAddToTextFeatureSelected: _showTextSection,
        ref: ref,
        context: context,
      );
      context.showToast(
        message: "Video Saved Successfully",
        toastType: ToastType.success,
      );
    } catch (e) {
      context.showToast(
        message: "Error while saving Video : $e",
        toastType: ToastType.error,
      );
    }
    ref.read(isSavingProvider.notifier).state = false;
  }

  Future<void> _cutVideo() async {
    ref.read(isCuttingProvider.notifier).state = true;
    var newVideoPath = await CustomHelper.cutVideo(
      videoPath: _videoPath ?? '',
      startingTime: _controller.startTrim.inSeconds.toDouble(),
      endingTime: _controller.endTrim.inSeconds.toDouble(),
    );
    _videoPath = newVideoPath;

    if (isInitialised) {
      await _controller.dispose();
    }

    setState(() {});

    _controller = VideoEditorController.file(
      File(_videoPath!),
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 600),
    )..initialize().then((_) {
        setState(() {});
      });
    ref.read(isCuttingProvider.notifier).state = false;
  }

  Future<void> _trimVideo() async {
    print('hhehe " ${_controller.startTrim.inSeconds.toDouble()}');
    print('hhehe 123 " ${_controller.endTrim.inSeconds.toDouble()}');
    ref.read(isTrimmingProvider.notifier).state = true;
    var newVideoPath = await CustomHelper.trimVideo(
      videoPath: _videoPath ?? '',
      startingTime: _controller.startTrim.inSeconds.toDouble(),
      endingTime: _controller.endTrim.inSeconds.toDouble(),
      videoLength: _controller.videoDuration,
    );
    _videoPath = newVideoPath;
    if (isInitialised) {
      await _controller.dispose();
    }
    setState(() {});
    _controller = VideoEditorController.file(
      File(_videoPath!),
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 600),
    )..initialize().then((_) {
        setState(() {});
      });
    ref.read(isTrimmingProvider.notifier).state = false;
  }

  Widget _functionalityButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    bool isLoading = false,
    bool isLast = false,
  }) {
    return Expanded(
      child: CustomButton(
        label: label,
        icon: icon,
        onTap: onTap,
        color: color,
        isLast: isLast,
        isLoading: isLoading,
      ),
    );
  }

  Widget _uploadVideo() {
    return InkWell(
      onTap: _pickVideo,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.green,
        ),
        child: Center(
          child: Text(
            _videoPath == null
                ? "Pick Video from Gallery"
                : "Choose another video",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _playPauseIcon() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) => AnimatedOpacity(
          opacity: _controller.isPlaying ? 0 : 1,
          duration: kThemeAnimationDuration,
          child: GestureDetector(
            onTap: _controller.video.play,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _trimSlider() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.90,
      child: TrimSlider(
        controller: _controller,
        horizontalMargin: 2,
        child: TrimTimeline(
          controller: _controller,
          padding: const EdgeInsets.only(top: 10),
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    final XFile? pickedFile =
        await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (isInitialised) {
        await _controller.dispose();
      }
      setState(() {
        _videoPath = pickedFile.path;
        _controller = VideoEditorController.file(
          File(_videoPath!),
          minDuration: const Duration(seconds: 1),
          maxDuration: const Duration(seconds: 600),
        );
      });
      await _controller.initialize();
      isInitialised = true;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
