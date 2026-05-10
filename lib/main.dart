import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:myapp/providers/NavProvider/index.dart';
import 'package:myapp/providers/StartupProvider/index.dart';
import 'package:myapp/providers/ThemeProvider/index.dart';
import 'package:myapp/providers/UserProvider/index.dart';
import 'package:myapp/router/IndexRouter/index.dart';
import 'package:myapp/service/Initialization/index.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await InitializationService.preRunInit();

  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => StartupProvider()),
      ],
      child: const IndexRouter(),
    ),
  );
}
