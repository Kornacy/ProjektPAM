import 'dart:io';
import 'package:flutter/material.dart';
import 'package:city_issues/services/camera_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _photo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zdjęcie')),
      body: Column(
        children: [
          Expanded(
            child: _photo != null
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.file(_photo!, fit: BoxFit.contain),
                  )
                : const Center(child: Text('Brak zdjęcia')),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final File? photo =
                          await CameraService.instance.takePhoto();
                      if (photo != null) {
                        setState(() => _photo = photo);
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Aparat'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final File? photo =
                          await CameraService.instance.pickFromGallery();
                      if (photo != null) {
                        setState(() => _photo = photo);
                      }
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeria'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}