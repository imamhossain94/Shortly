import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color color;
  final Color backgroundColor;

  const QrWidget({
    super.key,
    required this.data,
    this.size = 200,
    this.color = Colors.black,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        gapless: false,
        eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: color),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: color,
        ),
      ),
    );
  }
}
