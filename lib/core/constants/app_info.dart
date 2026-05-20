/// Informacje o aplikacji — wersja zgodna z pubspec.yaml.
class AppInfo {
  static const String appName = 'City Issues';
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  static String get versionLabel => '$version ($buildNumber)';

  static const String description =
      'Aplikacja umożliwia mieszkańcom szybkie zgłaszanie problemów '
      'infrastruktury miejskiej — dziur w jezdni, zepsutego oświetlenia, '
      'śmieci czy zaniedbań w zieleni. Zgłoszenia są geolokalizowane i '
      'udokumentowane zdjęciem, co ułatwia reakcję służb komunalnych.';

  static const List<({String name, String role})> creators = [
    (name: 'Maciej Bik', role: 'Frontend Developer'),
    (name: 'Kamil Buszta', role: 'Backend & DevOps'),
    (name: 'Jakub Wszołek', role: 'Product Lead & UX'),
  ];
}
