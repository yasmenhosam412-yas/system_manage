import 'package:flutter/material.dart';
import 'package:system_manage/core/utils/app_colors.dart';
import 'package:system_manage/core/utils/text_styles.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String? value)? validator;
  final String? Function(String? value)? onChanged;
  final Widget? prefixIcon;
  final int? maxLines;
  final bool? readOnly;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.maxLines = 1, this.readOnly, this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      maxLines: widget.maxLines,
      readOnly: widget.readOnly ?? false,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTextStyles.font16Black600.copyWith(
          color: AppColors.grey500,
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.grey500,
                ),
                onPressed: _toggleObscure,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grey500, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grey500, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grey500, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grey500, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

      ),
    );
  }
}
