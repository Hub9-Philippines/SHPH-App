import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: selected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      );
}
