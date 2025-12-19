import 'package:flutter/material.dart';

class HelpTooltip extends StatelessWidget {
  final String content;

  const HelpTooltip({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: content,
      waitDuration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            Icons.help_outline,
            size: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

