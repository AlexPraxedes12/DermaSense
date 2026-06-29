import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:derma_sense/core/localization/app_localizations.dart';
import 'package:derma_sense/core/theme/app_colors.dart';
import 'package:derma_sense/views/dashboard_screen.dart';

/// Widget raíz de la aplicación Derma Sense.
///
/// Configura el [MaterialApp]: tema Material 3, tipografía Inter (Google Fonts),
/// los estilos de botones y la pantalla inicial ([PressureMatDashboard]).
class MedicalMatApp extends StatefulWidget {
  const MedicalMatApp({super.key});

  @override
  State<MedicalMatApp> createState() => _MedicalMatAppState();
}

class _MedicalMatAppState extends State<MedicalMatApp> {
  Locale _locale = const Locale('es');

  void _setLocale(Locale locale) {
    if (_locale == locale) return;
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        brightness: Brightness.light,
        primary: AppColors.blue,
        secondary: AppColors.green,
        surface: AppColors.card,
        error: AppColors.red,
      ),
    );

    final textTheme = GoogleFonts.interTextTheme(baseTheme.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Derma Sense',
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: baseTheme.copyWith(
        textTheme: textTheme,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(146, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size(146, 48),
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: PressureMatDashboard(locale: _locale, onLocaleChanged: _setLocale),
    );
  }
}
