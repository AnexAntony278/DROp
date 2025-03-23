import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesService {
  static final AppPreferencesService _instance =
      AppPreferencesService._internal();
  late SharedPreferences _prefs;

  AppPreferencesService._internal();

  static AppPreferencesService get instance => _instance;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _prefs;
}
