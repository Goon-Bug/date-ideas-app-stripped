import 'package:flutter/material.dart';

class TitleContainer extends StatelessWidget {
  const TitleContainer({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Image.asset(
          imageUrl,
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.height * 0.3,
        ),
      ),
    );
  }
}

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? errorMessage;
  final Function(String) onChanged;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.errorMessage,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style:
          TextStyle(fontSize: 18, fontFamily: 'RetroSmall'), // Reduce font size
      decoration: InputDecoration(
        floatingLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
        labelText: labelText,
        labelStyle:
            TextStyle(fontFamily: 'RetroSmall', fontSize: 20), // Smaller label
        errorText: errorMessage,
        errorMaxLines: 2,
        errorStyle: TextStyle(
            fontSize: 14.0, fontFamily: 'RetroSmall'), // Smaller error text
        filled: true,
        fillColor: Theme.of(context).colorScheme.onPrimary,
        contentPadding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 14), // Reduce padding
        isDense: true, // Makes the field more compact
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Smaller border radius
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Smaller border radius
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.onPrimary),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
