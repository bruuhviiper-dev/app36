import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/app_theme.dart';
import 'screens/customize_screen.dart';
import 'screens/dates_screen.dart';
import 'screens/home_screen.dart';
import 'screens/more_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/ads_service.dart';
import 'services/app_state.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';
import 'services/widget_service.dart';
import 'widgets/banner_ad.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  final prefs = await SharedPreferences.getInstance();
  final appState = AppState(prefs);

  // Idioma do aparelho (pt/en/es) para notificações e textos gerados.
  final devLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  appState.lang = T.supported.contains(devLang) ? devLang : 'en';

  runApp(NossoAmorApp(appState: appState));

  // Inicializações pesadas DEPOIS do primeiro frame — assim a UI aparece na
  // hora (nada de tela rosa parada) e ads/compras/avisos sobem em segundo plano.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AdsService.instance.init();
    PurchaseService.instance
      ..onEntitlement((id) {
        appState.grantEntitlement(id);
        WidgetService.update(appState); // foto no widget libera na hora
      })
      ..init();
    if (appState.hasSetup && appState.reminderOn) {
      NotificationService.instance.reschedule(appState);
    }
  });
}

class NossoAmorApp extends StatelessWidget {
  const NossoAmorApp({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: Consumer<AppState>(
        builder: (context, s, _) => MaterialApp(
          onGenerateTitle: (ctx) => T.of(ctx).appName,
          debugShowCheckedModeBanner: false,
          // Segue o idioma do aparelho (pt / en / es); demais idiomas caem no en.
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: T.locales,
          localeResolutionCallback: (device, supported) {
            if (device != null) {
              for (final s in supported) {
                if (s.languageCode == device.languageCode) return s;
              }
            }
            return const Locale('en');
          },
          theme: AppTheme.light(s.theme.gradient.first),
          darkTheme: AppTheme.dark(s.theme.gradient.first),
          themeMode: s.themeMode,
          home: s.hasSetup ? const HomeShell() : const OnboardingScreen(),
        ),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetService.update(context.read<AppState>());
  }

  static const _screens = [
    HomeScreen(),
    DatesScreen(),
    CustomizeScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<AppState>().theme.gradient.last;
    final t = T.of(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(index: _index, children: _screens),
          ),
          const BannerPlaceholder(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        height: 66,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: accent.withValues(alpha: 0.18),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.favorite_border_rounded),
              selectedIcon: const Icon(Icons.favorite_rounded),
              label: t.navHome),
          NavigationDestination(
              icon: const Icon(Icons.event_outlined),
              selectedIcon: const Icon(Icons.event_rounded),
              label: t.navDates),
          NavigationDestination(
              icon: const Icon(Icons.palette_outlined),
              selectedIcon: const Icon(Icons.palette_rounded),
              label: t.navCustomize),
          NavigationDestination(
              icon: const Icon(Icons.more_horiz_rounded),
              selectedIcon: const Icon(Icons.more_horiz_rounded),
              label: t.navMore),
        ],
      ),
    );
  }
}
