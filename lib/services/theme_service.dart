import '../models/app_theme.dart';
import 'hive_database_service.dart';

class ThemeService {
  final HiveDatabaseService _hiveService;

  ThemeService(this._hiveService);

  Future<AppTheme> getTheme() async {
    final themeString = _hiveService.getTheme();
    return AppTheme.fromString(themeString);
  }

  Future<void> saveTheme(AppTheme theme) async {
    await _hiveService.saveTheme(theme.toString());
  }

  Future<void> toggleTheme(AppTheme currentTheme) async {
    final newTheme = AppTheme(
      type: currentTheme.isDark ? ThemeType.light : ThemeType.dark,
    );
    await saveTheme(newTheme);
  }
}
