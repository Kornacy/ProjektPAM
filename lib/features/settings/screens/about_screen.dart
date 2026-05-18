import 'package:flutter/material.dart';
import 'package:city_issues/core/constants/app_info.dart';
import 'package:city_issues/core/utils/scroll_padding.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('O aplikacji')),
      body: ListView(
        padding: ScrollPadding.list(context),
        children: [
          Center(
            child: Icon(
              Icons.location_city,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppInfo.appName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Wersja ${AppInfo.versionLabel}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),
          Text('Do czego służy', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(AppInfo.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          Text('Twórcy', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...AppInfo.creators.map(
            (c) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(c.name[0]),
                ),
                title: Text(c.name),
                subtitle: Text(c.role),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Projekt semestralny — Programowanie aplikacji mobilnych',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
