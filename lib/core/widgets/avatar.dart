import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Avatar extends StatelessWidget {
  final Uint8List? bytes;
  final String name;
  final double size;
  final double? radius;
  const Avatar({super.key, this.bytes, required this.name, this.size = 46, this.radius});

  String get _initials {
    final w = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (w.isEmpty) return '?';
    if (w.length == 1) return w.first[0].toUpperCase();
    return (w.first[0] + w.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: bytes == null ? AppColors.redGradient : null,
        borderRadius: BorderRadius.circular(radius ?? size * .3),
        image: bytes == null
            ? null
            : DecorationImage(image: MemoryImage(bytes!), fit: BoxFit.cover),
        boxShadow: [
          BoxShadow(
              color: AppColors.red.withValues(alpha: .5),
              blurRadius: 18,
              offset: const Offset(0, 8),
              spreadRadius: -6),
        ],
      ),
      child: bytes == null
          ? Text(_initials,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: size / 3))
          : null,
    );
  }
}