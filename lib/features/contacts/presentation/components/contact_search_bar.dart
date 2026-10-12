import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/debouncer.dart';

class ContactSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final String? initialQuery;

  const ContactSearchBar({
    super.key,
    required this.onSearch,
    this.initialQuery,
  });

  @override
  State<ContactSearchBar> createState() => ContactSearchBarState();
}

class ContactSearchBarState extends State<ContactSearchBar> {
  late final TextEditingController textController;
  late final Debouncer debouncer;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.initialQuery ?? '');
    debouncer = Debouncer(milliseconds: ApiConstants.debounceDurationMs);
  }

  void handleTextChanged(String value) {
    setState(() {});
    debouncer.run(() {
      widget.onSearch(value);
    });
  }

  void handleClearText() {
    textController.clear();
    setState(() {});
    debouncer.cancel();
    widget.onSearch('');
  }

  @override
  void dispose() {
    debouncer.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = textController.text.isNotEmpty;

    return Semantics(
      textField: true,
      label: 'Search contacts field',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: TextField(
          controller: textController,
          onChanged: handleTextChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search contacts...',
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 15,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF64748B),
              size: 22,
            ),
            suffixIcon: hasText
                ? IconButton(
                    icon: const Icon(
                      Icons.cancel_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    tooltip: 'Clear search',
                    onPressed: handleClearText,
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
