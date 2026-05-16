import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kontaku/core/utils/utils.dart';

class KontakuTextField extends StatelessWidget {
  const KontakuTextField({
    super.key,
    this.text,
    this.label,
    this.hintText,
    this.readOnly = false,
    this.expand = false,
    this.controller,
    this.onChanged,
    this.type,
  }) : assert(
         controller == null || text == null,
         'Use either controller or text, not both.',
       );

  final String? text;
  final String? label;
  final String? hintText;
  final bool readOnly;
  final bool expand;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? type;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: TextFormField(
        keyboardType: type,
        readOnly: readOnly,
        controller: controller,
        initialValue: controller == null ? text : null,
        onChanged: onChanged,
        expands: expand,
        minLines: expand ? null : 1,
        maxLines: expand ? null : 1,
        textAlignVertical: expand
            ? TextAlignVertical.top
            : TextAlignVertical.center,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          // color: const Color(0xFF1C2026),
          color: const Color(0xFF1C2026),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          alignLabelWithHint: expand,
          labelStyle: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1C2026),
          ),
          hintStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0x801C2026),
          ),
          filled: true,
          fillColor: Color(Kontaku.colors[6]),
          contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(Kontaku.colors[5]), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(Kontaku.colors[5]), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(Kontaku.colors[5]), width: 2),
          ),
        ),
      ),
    );
  }
}
