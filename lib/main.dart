import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mylibrary/ui/behaviors/AppLocalizations.dart';
import 'package:mylibrary/ui/widgets/AuthGate.dart';
import 'model/utils/Constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async{
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

}
class _MyAppState extends State<MyApp>{
  Locale _locale = const Locale('it');
  static final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blue);
  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, brightness: Brightness.dark);
  ThemeMode _themeMode = ThemeMode.dark;

  void changeLanguage(Locale locale){
    setState(() {
      _locale= locale;
    });
  }
  void changeThemeMode(){
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme){
      return MaterialApp(
        title: Constants.appName,
        locale: _locale,
        supportedLocales: const[
          Locale('it'),
          Locale('en'),
        ],
        localizationsDelegates: const[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
          useMaterial3: true
        ),
        themeMode: _themeMode,

        home: Authgate(changeLanguage: changeLanguage,changeThemeMode: changeThemeMode,),
      );
    });
  }
}


