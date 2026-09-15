import 'package:flutter/widgets.dart';

/// Traduções do app (pt / en / es). Escolhe pelo idioma do aparelho.
/// Uso: `final t = T.of(context);` e `t.homeTogetherFor`.
class T {
  T(this.l);
  final String l; // 'pt' | 'en' | 'es'

  static T of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return T(supported.contains(code) ? code : 'en');
  }

  static const supported = ['pt', 'en', 'es'];
  static const locales = [Locale('pt'), Locale('en'), Locale('es')];

  String _p(String pt, String en, String es) =>
      l == 'pt' ? pt : (l == 'es' ? es : en);

  // Nome do app (task switcher / recents).
  String get appName => _p('Nosso Amor', 'Our Love', 'Nuestro Amor');

  // Nomes dos temas por idioma.
  String themeName(String id) {
    switch (id) {
      case 'sunset':
        return _p('Rubi', 'Ruby', 'Rubí');
      case 'rosa':
        return _p('Rosa Neon', 'Neon Pink', 'Rosa Neón');
      case 'paixao':
        return _p('Paixão', 'Passion', 'Pasión');
      case 'lilas':
        return _p('Lilás', 'Lilac', 'Lila');
      case 'oceano':
        return _p('Oceano', 'Ocean', 'Océano');
      case 'dourado':
        return _p('Dourado', 'Gold', 'Dorado');
      case 'noite':
        return _p('Noite', 'Night', 'Noche');
      default:
        return '';
    }
  }

  // ---- Onboarding ----
  String get onbTitle => _p('Bem-vindos!', 'Welcome!', '¡Bienvenidos!');
  String get onbSubtitle => _p('Contem a história de vocês 💕',
      'Tell your love story 💕', 'Cuenten su historia 💕');
  String get yourName => _p('Seu nome', 'Your name', 'Tu nombre');
  String get partnerName =>
      _p('Nome do amor', "Partner's name", 'Nombre del amor');
  String get startDateHint => _p('Data de início do namoro',
      'Relationship start date', 'Fecha de inicio');
  String get start => _p('Começar 💖', 'Start 💖', 'Comenzar 💖');
  String get whenStarted => _p('Quando começou o namoro?',
      'When did it start?', '¿Cuándo empezó?');

  // ---- Nav ----
  String get navHome => _p('Início', 'Home', 'Inicio');
  String get navDates => _p('Datas', 'Dates', 'Fechas');
  String get navCustomize => _p('Personalizar', 'Customize', 'Personalizar');
  String get navMore => _p('Mais', 'More', 'Más');

  // ---- Home ----
  String get togetherFor =>
      _p('Estamos juntos há', 'Together for', 'Juntos hace');
  String day(int n) => _p(n == 1 ? 'dia 💞' : 'dias 💞',
      n == 1 ? 'day 💞' : 'days 💞', n == 1 ? 'día 💞' : 'días 💞');
  String orYmd(int y, int m, int d) {
    final ys = _p(y == 1 ? 'ano' : 'anos', y == 1 ? 'year' : 'years',
        y == 1 ? 'año' : 'años');
    final ms = _p(m == 1 ? 'mês' : 'meses', m == 1 ? 'month' : 'months',
        m == 1 ? 'mes' : 'meses');
    final ds = _p(d == 1 ? 'dia' : 'dias', d == 1 ? 'day' : 'days',
        d == 1 ? 'día' : 'días');
    final ou = _p('ou seja', "that's", 'o sea');
    return '$ou: $y $ys, $m $ms ${_p("e", "and", "y")} $d $ds';
  }

  String get messageOfDay =>
      _p('Mensagem do dia', 'Message of the day', 'Mensaje del día');
  String get questionOfDay =>
      _p('Pergunta do dia', 'Question of the day', 'Pregunta del día');
  String get answerTogether =>
      _p('respondam juntos 💕', 'answer together 💕', 'respondan juntos 💕');
  String get shareCounter => _p('Compartilhar o contador',
      'Share the counter', 'Compartir el contador');
  String shareText(String couple, int days, String msg) => _p(
      '$couple 💞\nEstamos juntos há $days dias!\n\n$msg',
      '$couple 💞\nTogether for $days days!\n\n$msg',
      '$couple 💞\n¡Juntos hace $days días!\n\n$msg');

  // milestones
  String milestoneToday(int d) => _p('🎉 Hoje são $d dias juntos!',
      "🎉 Today it's $d days together!", '🎉 ¡Hoy son $d días juntos!');
  String milestoneNext(int left, int target) => _p(
      'Faltam $left dias para $target dias juntos 🎯',
      '$left days left to $target days together 🎯',
      'Faltan $left días para $target días juntos 🎯');
  String get milestoneEvery => _p('💞 Cada dia é uma comemoração',
      '💞 Every day is a celebration', '💞 Cada día es una celebración');

  // ---- Dates ----
  String get datesTitle =>
      _p('Datas importantes', 'Important dates', 'Fechas importantes');
  String get anniversary =>
      _p('Aniversário', 'Anniversary', 'Aniversario');
  String get datingAnniversary => _p('Aniversário de namoro',
      'Relationship anniversary', 'Aniversario de novios');
  String get nextMilestones =>
      _p('Próximos marcos', 'Next milestones', 'Próximos hitos');
  String yearsTogether(int y) => _p('$y ${y == 1 ? "ano" : "anos"} juntos',
      '$y ${y == 1 ? "year" : "years"} together',
      '$y ${y == 1 ? "año" : "años"} juntos');
  String daysTogetherN(int d) => _p('$d dias juntos', '$d days together',
      '$d días juntos');
  String get ourDates => _p('Nossas datas', 'Our dates', 'Nuestras fechas');
  String get countdownSection =>
      _p('Contagem regressiva ⏳', 'Countdown ⏳', 'Cuenta regresiva ⏳');
  String get datesEmpty => _p(
      'Adicione datas especiais: 1º beijo, pedido, casamento… 💗',
      'Add special dates: first kiss, proposal, wedding… 💗',
      'Agrega fechas especiales: primer beso, pedida, boda… 💗');
  String get add => _p('Adicionar', 'Add', 'Agregar');
  String get newDate => _p('Nova data', 'New date', 'Nueva fecha');
  String get dateNameHint => _p('Ex.: 1º beijo, Pedido de namoro',
      'e.g. First kiss, Proposal', 'Ej.: Primer beso, Pedida');
  String get everyYear => _p('Todo ano', 'Every year', 'Cada año');
  String get countdown => _p('Contagem', 'Countdown', 'Regresiva');
  String get chooseDate => _p('Escolher data', 'Choose date', 'Elegir fecha');
  String get eventDate => _p('Data do evento', 'Event date', 'Fecha del evento');
  String get everyOn => _p('Todo', 'Every', 'Cada');
  String get cancel => _p('Cancelar', 'Cancel', 'Cancelar');
  String get save => _p('Salvar', 'Save', 'Guardar');
  String get isToday => _p('É hoje! 🎉', "It's today! 🎉", '¡Es hoy! 🎉');
  String get tomorrow => _p('Amanhã', 'Tomorrow', 'Mañana');
  String daysLeft(int d) =>
      _p('Faltam $d dias', '$d days left', 'Faltan $d días');
  String get daysRemaining =>
      _p('dias restantes', 'days left', 'días restantes');
  String get oneDayLeft => _p('falta 1 dia', '1 day left', 'falta 1 día');
  String get todayShort => _p('é hoje! 🎉', "today! 🎉", '¡hoy! 🎉');
  String get alreadyHappened =>
      _p('já aconteceu', 'already happened', 'ya pasó');

  // ---- Customize ----
  String get customizeTitle =>
      _p('Personalizar', 'Customize', 'Personalizar');
  String get namesAndDate =>
      _p('Nossos nomes e data', 'Our names and date', 'Nombres y fecha');
  String startedOn(String d) =>
      _p('início $d', 'started $d', 'inicio $d');
  String get couplePhoto => _p('Foto do casal', 'Couple photo', 'Foto de pareja');
  String get addPhoto => _p('Adicionar uma foto', 'Add a photo', 'Agregar foto');
  String get changePhoto => _p('Trocar a foto', 'Change photo', 'Cambiar foto');
  String get darkMode => _p('Modo escuro', 'Dark mode', 'Modo oscuro');
  String get coupleTheme => _p('Tema do casal', 'Couple theme', 'Tema de pareja');
  String get ourProfile => _p('Nosso perfil', 'Our profile', 'Nuestro perfil');
  String get unlockThemesTitle => _p('Libere todos os temas 🎨',
      'Unlock all themes 🎨', '¡Desbloquea todos los temas! 🎨');
  String get unlockThemesBody => _p(
      'Assista um vídeo e use por 24h, ou tenha o Premium pra sempre.',
      'Watch a video for 24h, or get Premium forever.',
      'Mira un video por 24h, u obtén Premium para siempre.');
  String get video24h => _p('Vídeo 24h', 'Video 24h', 'Video 24h');
  String get premium => _p('Premium', 'Premium', 'Premium');
  String get premiumTheme =>
      _p('Tema premium 🔒', 'Premium theme 🔒', 'Tema premium 🔒');
  String get watchVideo24h => _p('Assistir vídeo (24h)',
      'Watch video (24h)', 'Ver video (24h)');
  String get premiumForever => _p('Premium (pra sempre)',
      'Premium (forever)', 'Premium (para siempre)');
  String get loadingVideo =>
      _p('Carregando vídeo…', 'Loading video…', 'Cargando video…');
  String get videoUnavailable => _p('Vídeo indisponível, tente de novo.',
      'Video unavailable, try again.', 'Video no disponible, intenta de nuevo.');
  String get themesUnlockedTemp => _p('Temas liberados por vídeo — aproveite! ⏳',
      'Themes unlocked by video — enjoy! ⏳',
      'Temas desbloqueados por video — ¡disfruta! ⏳');

  // ---- More ----
  String get moreTitle => _p('Mais', 'More', 'Más');
  String get premiumTitle => _p('Nosso Amor Premium',
      'Our Love Premium', 'Nuestro Amor Premium');
  String get premiumSubtitle => _p('Sem anúncios + todos os temas 💖',
      'No ads + all themes 💖', 'Sin anuncios + todos los temas 💖');
  String get widgetTile =>
      _p('Widget na tela inicial', 'Home screen widget', 'Widget en inicio');
  String get widgetTileSub => _p('Adicione o contador com 1 toque 🏠',
      'Add the counter with 1 tap 🏠', 'Agrega el contador con 1 toque 🏠');
  String get remindersTile => _p('Avisos e mensagem do dia',
      'Reminders and daily message', 'Avisos y mensaje del día');
  String get remindersSub => _p('Datas especiais + mensagem de amor diária',
      'Special dates + daily love message',
      'Fechas especiales + mensaje de amor diario');
  String get remindersOn => _p('Avisos ativados 💞',
      'Reminders enabled 💞', 'Avisos activados 💞');
  String get rateApp =>
      _p('Avaliar na Play Store', 'Rate on Play Store', 'Calificar en Play Store');
  String get rateSub => _p('Sua nota ajuda muito 💛',
      'Your rating helps a lot 💛', 'Tu calificación ayuda 💛');
  String get shareApp => _p('Compartilhar o app', 'Share the app', 'Compartir la app');
  String get moreApps => _p('Mais apps da Phantom',
      'More apps by Phantom', 'Más apps de Phantom');
  String get byDeveloper => _p('Por:', 'By:', 'Por:');
  String get seeAllApps =>
      _p('Ver todos os apps', 'See all apps', 'Ver todas las apps');
  String get openApp => _p('Abrir', 'Open', 'Abrir');
  String shareAppText(String url) => _p('Conheça o Nosso Amor! $url',
      'Check out Our Love! $url', '¡Conoce Nuestro Amor! $url');

  // ---- Widget screen ----
  String get widgetScreenTitle => _p('Widget na tela inicial',
      'Home screen widget', 'Widget en la pantalla');
  String get widgetHeadline => _p('Veja os dias de vocês sem abrir o app 🏠',
      'See your days without opening the app 🏠',
      'Vean sus días sin abrir la app 🏠');
  String get widgetSub => _p(
      'O widget mostra o contador direto na tela inicial, com a cor do tema.',
      'The widget shows the counter on your home screen, in your theme color.',
      'El widget muestra el contador en el inicio, con el color del tema.');
  String get widgetDaysTogether =>
      _p('dias juntos 💞', 'days together 💞', 'días juntos 💞');
  String get widgetStyle => _p('Estilo do widget', 'Widget style', 'Estilo del widget');
  String get styleFull => _p('Completo', 'Full', 'Completo');
  String get styleMinimal => _p('Minimalista', 'Minimal', 'Minimalista');
  String get styleHeart => _p('Coração', 'Heart', 'Corazón');
  String get addToHome => _p('Adicionar à tela inicial',
      'Add to home screen', 'Agregar a la pantalla');
  String get widgetManualTitle => _p('Não abriu automaticamente?',
      "Didn't open automatically?", '¿No se abrió solo?');
  String get widgetManualSteps => _p(
      '1. Segure num espaço vazio da tela inicial\n2. Toque em "Widgets"\n3. Procure "Nosso Amor"\n4. Arraste para a tela 💞',
      '1. Long-press an empty spot on your home screen\n2. Tap "Widgets"\n3. Find "Our Love"\n4. Drag it to the screen 💞',
      '1. Mantén pulsado un espacio vacío\n2. Toca "Widgets"\n3. Busca "Nuestro Amor"\n4. Arrástralo a la pantalla 💞');
  String get widgetAddManual => _p('Use as instruções abaixo para adicionar 👇',
      'Use the steps below to add it 👇',
      'Usa los pasos de abajo para agregarlo 👇');

  // ---- Store ----
  String get storeTitle => _p('Premium 💖', 'Premium 💖', 'Premium 💖');
  String get youArePremium =>
      _p('Você é Premium!', "You're Premium!", '¡Eres Premium!');
  String get premiumHeadline => _p('Nosso Amor Premium',
      'Our Love Premium', 'Nuestro Amor Premium');
  String get premiumThanks => _p(
      'Obrigado pelo apoio 💕 Aproveitem tudo, sem anúncios.',
      'Thanks for your support 💕 Enjoy everything, ad-free.',
      'Gracias por tu apoyo 💕 Disfruten todo, sin anuncios.');
  String get premiumPitch => _p('Tudo isto, pra sempre, com um pagamento único:',
      'All this, forever, with a single payment:',
      'Todo esto, para siempre, con un pago único:');
  String get perkNoAds =>
      _p('🚫  Sem nenhum anúncio', '🚫  No ads at all', '🚫  Sin anuncios');
  String get perkThemes => _p('🎨  Todos os temas e cores, pra sempre',
      '🎨  All themes and colors, forever',
      '🎨  Todos los temas y colores, para siempre');
  String get perkWidget => _p('🏠  Widget na tela inicial',
      '🏠  Home screen widget', '🏠  Widget en la pantalla');
  String get perkPhoto => _p('📷  Foto do casal no widget',
      '📷  Couple photo on the widget', '📷  Foto de pareja en el widget');
  String buyPremium(String price) => _p('Quero o Premium  •  $price',
      'Get Premium  •  $price', 'Quiero Premium  •  $price');
  String get restore => _p('Restaurar compra', 'Restore purchase', 'Restaurar compra');
  String get processing => _p('Processando…', 'Processing…', 'Procesando…');
  String get allFree => _p('Tudo isto é grátis', 'All this is free', 'Todo esto es gratis');
  String get freeCounter => _p('Contador de dias juntos',
      'Days-together counter', 'Contador de días juntos');
  String get freeDates => _p('Datas importantes com contagem',
      'Important dates with countdown', 'Fechas importantes con cuenta');
  String get freeWidget => _p('Widget na tela inicial',
      'Home screen widget', 'Widget en la pantalla');
  String get freeMessage => _p('Mensagem de amor todo dia',
      'Daily love message', 'Mensaje de amor cada día');
}
