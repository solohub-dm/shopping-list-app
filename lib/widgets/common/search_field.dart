import 'package:flutter/material.dart';
import 'package:shopping_list_app/utils/app_constants.dart';

class SearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final String? value;

  const SearchField({
    super.key,
    required this.hintText,
    this.onChanged,
    this.value,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColorScheme.getBorderMedium(context);
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
      borderSide: BorderSide(
        color: borderColor,
        width: AppSizes.borderWidthThin,
      ),
    );

    return SizedBox(
      height: AppSizes.inputHeight,
      child: TextField(
        controller: _controller,
        style: TextStyle(
          color: AppColorScheme.getTextPrimary(context),
          fontSize: AppSizes.inputFontSize,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColorScheme.getTextTertiary(context),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: AppSizes.iconSizeSmall,
            color: AppColorScheme.getTextTertiary(context),
          ),
          filled: true,
          fillColor: AppColorScheme.getBgPrimary(context),
          enabledBorder: defaultBorder,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.inputBorderRadius),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: AppSizes.borderWidthMedium,
            ),
          ),
          contentPadding: AppSizes.inputPadding,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}