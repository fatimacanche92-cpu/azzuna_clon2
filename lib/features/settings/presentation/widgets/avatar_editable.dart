import 'dart:io'; // Import for File
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';

class AvatarEditable extends ConsumerWidget {
  final String? imageUrl;
  final String? imagePath; // New field for local path
  final double radius;
  final VoidCallback onEditPressed;

  const AvatarEditable({
    Key? key,
    this.imageUrl,
    this.imagePath,
    this.radius = 60,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ImageProvider? backgroundImage;
    if (imagePath != null && imagePath!.isNotEmpty) {
      backgroundImage = FileImage(File(imagePath!));
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      backgroundImage = NetworkImage(imageUrl!);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          key: ValueKey(imagePath ?? imageUrl), // Force rebuild on change
          radius: radius,
          backgroundColor: AppColors.roseQuartz,
          backgroundImage: backgroundImage,
          child: (backgroundImage == null)
              ? Icon(Icons.person, size: radius, color: Colors.white)
              : null,
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: FloatingActionButton(
            heroTag: 'editAvatar',
            onPressed: onEditPressed,
            backgroundColor: AppColors.redWine,
            child: const Icon(Icons.edit, size: 20),
          ),
        ),
      ],
    );
  }
}
