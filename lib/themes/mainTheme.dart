import 'package:balanceit/themes/colors.dart';
import 'package:flutter/material.dart';

final ThemeData mainTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFFF4F4F4),
  colorScheme: ColorScheme(
    primary: mainColor,
    // основной цвет
    secondary: secondColor,
    // цвет акцента
    surface: surfaceColor,
    // цвет поверхности (например, фона)
    background: surfaceColor,
    // цвет заднего фона
    error: Colors.red,
    // цвет ошибки
    onPrimary: Colors.white,
    // цвет текста на основном цвете
    onSecondary: Colors.white,
    // цвет текста на вторичном цвете
    onSurface: Colors.black,
    // цвет текста на поверхности
    onBackground: Colors.black,
    // цвет текста на заднем фоне
    onError: Colors.white,
    // цвет текста на ошибке
    brightness: Brightness.light, // яркость (светлая или темная тема)
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    // черный текст для основного контента
    bodyMedium: TextStyle(color: Colors.grey),
    // серый текст для дополнительного контента
    titleLarge: TextStyle(color: Colors.white), // белый текст для заголовка
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(buttonColor), // бирюзовый цвет для кнопок
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // цвет текста для кнопок
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: buttonColor, // бирюзовый цвет для кнопок
    textTheme: ButtonTextTheme.primary,
  ),
);