import 'dart:io';
import 'package:flutter/material.dart';
import 'package:city_issues/services/camera_service.dart';
import 'package:city_issues/services/report_service.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final TextEditingController _descController = TextEditingController();
  final List<File> _photos = [];

  // TODO: zastąpić listą kategorii pobraną z bazy
  String? _selectedCategoryId;
  final List<Map<String, String>> _categories = [
    {'id': 'DROGI', 'name': 'Drogi'},
    {'id': 'OSWIETLENIE', 'name': 'Oświetlenie'},
    {'id': 'SMIECI', 'name': 'Śmieci'},
    {'id': 'INNE', 'name': 'Inne'},
  ];

  bool _isLoading = false;
  String? _error;

  Future<void> _addPhoto() async {
    final File? photo = await CameraService.instance.showPickerDialog(context);
    if (photo != null) {
      setState(() => _photos.add(photo));
    }
  }

  Future<void> _submit() async {
    if (_selectedCategoryId == null) {
      setState(() => _error = 'Wybierz kategorię.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ReportService.instance.createReport(
        categoryId: _selectedCategoryId!,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        photos: _photos,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zgłoszenie zostało dodane.')),
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      setState(() => _error = '$e\n$stackTrace');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nowe zgłoszenie')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategoria
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kategoria',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategoryId,
              items: _categories
                  .map((c) => DropdownMenuItem(
                        value: c['id'],
                        child: Text(c['name']!),
                      ))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedCategoryId = value),
            ),
            const SizedBox(height: 16),

            // Opis
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Opis (opcjonalny)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Zdjęcia
            Text('Zdjęcia', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._photos.map(
                  (photo) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          photo,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _photos.remove(photo)),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _addPhoto,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_a_photo,
                        color: Colors.grey, size: 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // TODO: dodać wybór lokalizacji z mapy

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Wyślij zgłoszenie'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }
}