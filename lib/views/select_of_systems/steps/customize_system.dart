import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:system_manage/core/utils/app_padding.dart';
import 'package:system_manage/core/utils/app_texts.dart';
import 'package:system_manage/core/utils/toasts.dart';
import 'package:system_manage/core/widgets/custom_button.dart';

import '../../../core/utils/app_colors.dart';
import '../../../helpers/create_material_color.dart';

class CustomizeSystem extends StatefulWidget {
  final Function(String image) onNext;

  const CustomizeSystem({super.key, required this.onNext});

  @override
  State<CustomizeSystem> createState() => _CustomizeSystemState();
}

class _CustomizeSystemState extends State<CustomizeSystem> {
  XFile? _selectedImage;
  Color _primaryColor = Colors.blue;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppTexts.primaryColor),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _primaryColor,
              onColorChanged: (color) {
                setState(() {
                  _primaryColor = color;
                });
              },
              enableAlpha: false,
              showLabel: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppTexts.done),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(AppTexts.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickImage,
            child: _selectedImage == null
                ? Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_a_photo, size: 50),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_selectedImage!.path),
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          // const SizedBox(height: 24),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       AppTexts.primaryColor,
          //       style: Theme.of(context).textTheme.titleMedium,
          //     ),
          //     GestureDetector(
          //       onTap: _pickColor,
          //       child: Container(
          //         width: 40,
          //         height: 40,
          //         decoration: BoxDecoration(
          //           color: _primaryColor,
          //           borderRadius: BorderRadius.circular(8),
          //           border: Border.all(color: Colors.black26),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: AppPadding.medium),
          CustomButton(
            text: "Next",
            onPressed: () {
              if (_selectedImage?.path != null) {
                widget.onNext(_selectedImage?.path ?? "");
              }else{
                Toasts.displayToast(AppTexts.selectImage,AppColors.grey800);
              }
            },
          ),
        ],
      ),
    );
  }
}
