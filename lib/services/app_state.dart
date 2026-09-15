import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_theme.dart';
import '../data/couple_date.dart';

/// Estado global do casal — tudo salvo localmente (privado do aparelho).
class AppState extends ChangeNotifier {
  AppState(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;

  static const _kName1 = 'name1';
  static const _kName2 = 'name2';
  static const _kStart = 'start_millis';
  static const _kPhoto = 'photo_path';
  static const _kTheme = 'theme_id';
  static const _kEntitlements = 'entitlements';
  static const _kTempPro = 'temp_pro_until';
  static const _kReminderOn = 'reminder_on';
  static const _kReminderHour = 'reminder_hour';
  static const _kReminderMin = 'reminder_min';
  static const _kDark = 'dark';
  static const _kDates = 'dates';
  static const _kWidgetStyle = 'widget_style';

  static const String pPremium = 'no_ads'; // remove ads + libera tudo

  String _name1 = '';
  String _name2 = '';
  DateTime? _start;
  String _photoPath = '';
  String _themeId = 'sunset';
  final Set<String> _entitlements = {};
  DateTime? _tempProUntil;
  bool _reminderOn = true;
  int _reminderHour = 9;
  int _reminderMin = 0;
  bool _dark = false;
  final List<CoupleDate> _dates = [];

  // ---- getters ----
  String get name1 => _name1;
  String get name2 => _name2;
  DateTime? get startDate => _start;
  String get photoPath => _photoPath;
  bool get hasSetup => _start != null && _name1.isNotEmpty;
  String get coupleLabel =>
      (_name1.isNotEmpty && _name2.isNotEmpty) ? '$_name1 & $_name2' : 'Nós dois';

  CoupleTheme get theme => CoupleTheme.byId(_themeId);
  String get themeId => _themeId;

  bool get isDark => _dark;
  ThemeMode get themeMode => _dark ? ThemeMode.dark : ThemeMode.light;

  bool get reminderOn => _reminderOn;
  int get reminderHour => _reminderHour;
  int get reminderMin => _reminderMin;

  // ---- premium / desbloqueios ----
  bool get isPremium => _entitlements.contains(pPremium);
  bool get adsRemoved => isPremium;
  bool get hasTemporaryPro =>
      _tempProUntil != null && _tempProUntil!.isAfter(DateTime.now());
  bool get hasThemeAccess => isPremium || hasTemporaryPro;
  Duration? get temporaryProLeft =>
      hasTemporaryPro ? _tempProUntil!.difference(DateTime.now()) : null;

  bool ownsTheme(String id) {
    final t = CoupleTheme.byId(id);
    return !t.premium || hasThemeAccess;
  }

  // ---- contagem ----
  int get daysTogether {
    if (_start == null) return 0;
    final now = DateTime.now();
    final a = DateTime(_start!.year, _start!.month, _start!.day);
    final b = DateTime(now.year, now.month, now.day);
    return b.difference(a).inDays;
  }

  /// Anos, meses e dias desde o início (aproximado por calendário).
  (int, int, int) get ymd {
    if (_start == null) return (0, 0, 0);
    final now = DateTime.now();
    int years = now.year - _start!.year;
    int months = now.month - _start!.month;
    int days = now.day - _start!.day;
    if (days < 0) {
      months -= 1;
      days += DateTime(now.year, now.month, 0).day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    return (years, months, days);
  }

  // ---- setters ----
  void setup({
    required String name1,
    required String name2,
    required DateTime start,
  }) {
    _name1 = name1.trim();
    _name2 = name2.trim();
    _start = start;
    _prefs.setString(_kName1, _name1);
    _prefs.setString(_kName2, _name2);
    _prefs.setInt(_kStart, start.millisecondsSinceEpoch);
    notifyListeners();
  }

  void setPhoto(String path) {
    _photoPath = path;
    _prefs.setString(_kPhoto, path);
    notifyListeners();
  }

  void setTheme(String id) {
    if (!ownsTheme(id)) return;
    _themeId = id;
    _prefs.setString(_kTheme, id);
    notifyListeners();
  }

  void toggleDark() {
    _dark = !_dark;
    _prefs.setBool(_kDark, _dark);
    notifyListeners();
  }

  // Idioma do aparelho (pt/en/es) — definido no startup, usado p/ notificações.
  String lang = 'pt';

  // ---- estilo do widget ----
  String _widgetStyle = 'full'; // full | minimal | heart
  String get widgetStyle => _widgetStyle;
  void setWidgetStyle(String style) {
    _widgetStyle = style;
    _prefs.setString(_kWidgetStyle, style);
    notifyListeners();
  }

  void grantTemporaryPro(Duration d) {
    _tempProUntil = DateTime.now().add(d);
    _prefs.setInt(_kTempPro, _tempProUntil!.millisecondsSinceEpoch);
    notifyListeners();
  }

  void grantEntitlement(String id) {
    if (_entitlements.add(id)) {
      _prefs.setStringList(_kEntitlements, _entitlements.toList());
      notifyListeners();
    }
  }

  // ---- datas importantes ----
  /// Datas recorrentes (aniversários), ordenadas pela mais próxima.
  List<CoupleDate> get dates {
    final list = _dates.where((d) => d.recurring).toList();
    list.sort((a, b) => a.daysUntilNext().compareTo(b.daysUntilNext()));
    return list;
  }

  /// Contagens regressivas (datas únicas futuras), da mais próxima pra frente.
  List<CoupleDate> get countdowns {
    final list = _dates.where((d) => !d.recurring).toList();
    list.sort((a, b) => a.daysUntilNext().compareTo(b.daysUntilNext()));
    return list;
  }

  void addDate(String name, DateTime date,
      {String emoji = '💗', bool recurring = true}) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    _dates.add(
        CoupleDate(id, name.trim(), date, emoji: emoji, recurring: recurring));
    _saveDates();
    notifyListeners();
  }

  void removeDate(String id) {
    _dates.removeWhere((d) => d.id == id);
    _saveDates();
    notifyListeners();
  }

  void _saveDates() =>
      _prefs.setStringList(_kDates, [for (final d in _dates) d.serialize()]);

  void setReminder({required bool on, int? hour, int? minute}) {
    _reminderOn = on;
    if (hour != null) _reminderHour = hour;
    if (minute != null) _reminderMin = minute;
    _prefs.setBool(_kReminderOn, on);
    _prefs.setInt(_kReminderHour, _reminderHour);
    _prefs.setInt(_kReminderMin, _reminderMin);
    notifyListeners();
  }

  void _load() {
    _name1 = _prefs.getString(_kName1) ?? '';
    _name2 = _prefs.getString(_kName2) ?? '';
    final s = _prefs.getInt(_kStart);
    _start = s != null ? DateTime.fromMillisecondsSinceEpoch(s) : null;
    _photoPath = _prefs.getString(_kPhoto) ?? '';
    _themeId = _prefs.getString(_kTheme) ?? 'sunset';
    _entitlements.addAll(_prefs.getStringList(_kEntitlements) ?? const []);
    final tp = _prefs.getInt(_kTempPro);
    _tempProUntil = tp != null ? DateTime.fromMillisecondsSinceEpoch(tp) : null;
    _reminderOn = _prefs.getBool(_kReminderOn) ?? true;
    _reminderHour = _prefs.getInt(_kReminderHour) ?? 9;
    _reminderMin = _prefs.getInt(_kReminderMin) ?? 0;
    _dark = _prefs.getBool(_kDark) ?? false;
    _widgetStyle = _prefs.getString(_kWidgetStyle) ?? 'full';
    for (final s in _prefs.getStringList(_kDates) ?? const []) {
      final d = CoupleDate.parse(s);
      if (d != null) _dates.add(d);
    }
    if (!ownsTheme(_themeId)) _themeId = 'sunset';
  }
}
