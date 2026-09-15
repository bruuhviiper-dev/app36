/// Identidade do app + catálogo (cross-promoção).
class AppInfo {
  AppInfo._();

  static const developer = 'Phantom Tecnologia';
  static const appName = 'Nosso Amor';
  static const packageId = 'com.nossoamor.contador';

  static String playUrlFor(String id) =>
      'https://play.google.com/store/apps/details?id=$id';

  static const playUrl =
      'https://play.google.com/store/apps/details?id=$packageId';
  static const devUrl =
      'https://play.google.com/store/apps/developer?id=Phantom+Tecnologia';

  static const List<(String, String)> apps = [
    ('Horóscopo do Dia e Signos', 'com.horoscopododia.horoscopo'),
    ('Frases de Amor e Romance', 'com.frasesdeamor.amor'),
    ('Calendário 2026 2027 Feriados', 'com.calendarioferiados.calendario'),
    ('Cantadas para Conquistar', 'com.cantadas.cantadas'),
    ('Frases em Inglês com Tradução', 'com.frasesemingles.ingles'),
  ];

  static List<(String, String)> get otherApps =>
      apps.where((a) => a.$2 != packageId).toList();
}
