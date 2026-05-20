class AuthValidation {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Podaj adres e-mail.';
    }
    final email = value.trim();
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      return 'Nieprawidłowy adres e-mail.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Podaj hasło.';
    }
    if (value.length < 8) {
      return 'Hasło musi mieć co najmniej 8 znaków.';
    }
    return null;
  }

  static String? validatePasswordConfirm(String? password, String? confirm) {
    if (confirm == null || confirm.isEmpty) {
      return 'Potwierdź hasło.';
    }
    if (password != confirm) {
      return 'Hasła nie są identyczne.';
    }
    return null;
  }
}
