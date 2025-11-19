import 'package:flutter/material.dart';

class AppTheme {
  // Navy Blue Palette from the screenshot
  static const Color primaryNavy = Color(0xFF001F54); 
  static const Color darkerNavy = Color(0xFF001233); // Background
  static const Color cardColor = Color(0xFF0A2A5E);  // Slightly lighter navy for cards
  static const Color accentBlue = Color(0xFF1A73E8);
  static const Color white = Colors.white;

  static ThemeData get theme {
    // Start with dark theme to handle text colors correctly
    final base = ThemeData.dark(useMaterial3: true);
    
    return base.copyWith(
      scaffoldBackgroundColor: darkerNavy,
      primaryColor: primaryNavy,
      colorScheme: base.colorScheme.copyWith(
        primary: white,
        secondary: accentBlue,
        surface: cardColor,
        onSurface: white,
        background: darkerNavy,
        onBackground: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkerNavy,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20, 
          fontWeight: FontWeight.bold
        ),
      ),
      // Navigation Bar Theme (Bottom Tab)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkerNavy,
        selectedItemColor: white, // Active tab is white
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: white,
        textColor: white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white10,
        thickness: 1,
      ),
      // Text Fields for Dark Mode
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
