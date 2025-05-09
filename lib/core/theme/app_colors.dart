import 'package:flutter/material.dart';

class AppColors {
  // Основний колір Лімо
  static const Color primary = Color(0xFF1B4B8F); // Темно-синій
  static const Color secondary = Color(0xFFF7B500); // Жовтий
  static const Color accent = Color(0xFFE30613); // Червоний

  // Відтінки основного кольору
  static const Color primaryLight = Color(0xFF4A7AB8);
  static const Color primaryDark = Color(0xFF0D2B5C);

  // Нейтральні кольори
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFE30613);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Текстові кольори
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Colors.white;
  static const Color textHint = Color(0xFF9E9E9E);

  // Кольори для графіків
  static const List<Color> chartColors = [
    Color(0xFF1B4B8F), // Основний синій
    Color(0xFFF7B500), // Жовтий
    Color(0xFFE30613), // Червоний
    Color(0xFF4CAF50), // Зелений
    Color(0xFF9C27B0), // Фіолетовий
    Color(0xFFFF9800), // Оранжевий
    Color(0xFF00BCD4), // Бірюзовий
    Color(0xFF795548), // Коричневий
    Color(0xFF607D8B), // Сірий
    Color(0xFF8BC34A), // Світло-зелений
  ];
}
