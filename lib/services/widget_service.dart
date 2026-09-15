import 'dart:io';

import 'package:home_widget/home_widget.dart';

import 'app_state.dart';

/// Atualiza o widget da tela inicial (nomes + dias + cor do tema + foto).
///
/// A foto no widget é feita de forma SEGURA: mandamos só o caminho do arquivo
/// e o provider nativo decodifica/reduz o bitmap. Nada de `renderFlutterWidget`
/// (que naquela versão travava o app com loop de SurfaceTexture).
class WidgetService {
  WidgetService._();

  static Future<void> update(AppState s) async {
    try {
      final photo = (s.hasThemeAccess &&
              s.photoPath.isNotEmpty &&
              File(s.photoPath).existsSync())
          ? s.photoPath
          : '';
      await HomeWidget.saveWidgetData<String>('couple', s.coupleLabel);
      await HomeWidget.saveWidgetData<String>('days', s.daysTogether.toString());
      await HomeWidget.saveWidgetData<String>('theme', s.themeId);
      await HomeWidget.saveWidgetData<String>('photoPath', photo);
      await HomeWidget.saveWidgetData<String>('style', s.widgetStyle);
      await HomeWidget.updateWidget(androidName: 'CoupleWidgetProvider');
    } catch (_) {}
  }

  /// Pede pro Android adicionar o widget com 1 toque (API 26+).
  static Future<bool> requestPin() async {
    try {
      await HomeWidget.requestPinWidget(
        name: 'CoupleWidgetProvider',
        androidName: 'CoupleWidgetProvider',
        qualifiedAndroidName: 'com.nossoamor.contador.CoupleWidgetProvider',
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
