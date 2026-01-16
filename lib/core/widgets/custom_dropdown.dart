import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String hint;
  final double borderRadius;

  const CustomDropdown({
    super.key,
    this.value,
    required this.items,
    required this.onChanged,
    this.hint = 'Select',
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final T? selectedValue = value ?? (items.isNotEmpty ? items.first.value : null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          dropdownColor: Colors.white,
          value: selectedValue,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
