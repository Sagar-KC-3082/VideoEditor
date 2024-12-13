import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_editor_demo/core/context_extension.dart';
import 'package:video_editor_demo/core/custom_button.dart';
import 'package:video_editor_demo/core/widgets/custom_textfield.dart';

/// @author: Sagar K.C.
/// @email: sagar.kc@fonepay.com
/// @created_at: 11/22/2024, Friday

final backgroundColorProvider = StateProvider<Color>((ref) => Colors.black);
final textColorProvider = StateProvider<Color>((ref) => Colors.white);
final textProvider = StateProvider<String>((ref) => 'Default Text');
final offsetProvider = StateProvider<Offset>((ref) => const Offset(0, 0));

class DraggableTextWidget extends ConsumerStatefulWidget {
  const DraggableTextWidget({super.key});

  @override
  ConsumerState<DraggableTextWidget> createState() =>
      _DraggableTextWidgetState();
}

class _DraggableTextWidgetState extends ConsumerState<DraggableTextWidget> {
  Offset _offset = const Offset(0, 0);
  final TextEditingController _textEditingController = TextEditingController();
  final double _fontSize = 20;
  final GlobalKey _containerKey = GlobalKey();

  RenderBox? _renderBox;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ref.watch(backgroundColorProvider);
    final textColor = ref.watch(textColorProvider);
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onTap: () {
          _showBottomSheet(context, backgroundColor, textColor);
        },
        onPanUpdate: (details) {
          setState(() {
            _offset = Offset(
              _offset.dx + details.delta.dx,
              _offset.dy + details.delta.dy,
            );
          });

          final Offset? position = _renderBox?.localToGlobal(Offset.zero);
          ref.read(offsetProvider.notifier).state = Offset(
            position?.dx ?? 50.0,
            position?.dy ?? 50.0,
          );
        },
        child: Container(
          key: _containerKey,
          color: backgroundColor,
          padding: const EdgeInsets.all(6),
          child: Text(
            _textEditingController.text.isEmpty
                ? "Tap to add Text"
                : _textEditingController.text,
            style: TextStyle(
              color: textColor,
              fontSize: _fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showBottomSheet(
    BuildContext context,
    Color backgroundColor,
    Color textColor,
  ) {
    return showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _textEditingController,
                onChanged: (String? value) {
                  ref.read(textProvider.notifier).state = value ?? '';
                  setState(() {});
                },
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              _functionalityRow(
                backgroundColor: backgroundColor,
                textColor: textColor,
              ),
              const SizedBox(height: 24),
              _saveAndRemoveRow(context),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Row _saveAndRemoveRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.green,
              ),
              child: const Center(
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (_textEditingController.text.isNotEmpty)
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _textEditingController.clear();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.green,
                ),
                child: const Center(
                  child: Text(
                    "Remove",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }

  Row _functionalityRow({
    required Color textColor,
    required Color backgroundColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            label: 'Color',
            icon: Icons.color_lens_outlined,
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  builder: (context) {
                    return SizedBox(
                      width: double.infinity,
                      child: BlockPicker(
                        availableColors: const [
                          Colors.red,
                          Colors.green,
                          Colors.blue,
                          Colors.yellow,
                          Colors.orange,
                          Colors.purple,
                          Colors.black,
                          Colors.white,
                        ],
                        onColorChanged: (color) {
                          ref.read(textColorProvider.notifier).state = color;
                          Navigator.of(context).pop();
                        },
                        pickerColor: textColor,
                      ),
                    );
                  });
            },
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        /* Expanded(
          child: CustomButton(
            label: 'Size',
            icon: Icons.text_fields_rounded,
            onTap: () {
              context.showToast(message: "Coming Soon");
            },
            color: Colors.pink,
          ),
        ),
        const SizedBox(width: 8),*/
        Expanded(
          child: CustomButton(
            label: 'Background',
            icon: Icons.format_color_fill_sharp,
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  builder: (context) {
                    return BlockPicker(
                      availableColors: const [
                        Colors.red,
                        Colors.green,
                        Colors.blue,
                        Colors.yellow,
                        Colors.orange,
                        Colors.purple,
                        Colors.black,
                        Colors.white,
                      ],
                      onColorChanged: (color) {
                        ref.read(backgroundColorProvider.notifier).state =
                            color;
                        Navigator.of(context).pop();
                      },
                      pickerColor: backgroundColor,
                    );
                  });
            },
            color: Colors.amber,
            isLast: true,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
