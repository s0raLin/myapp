import 'package:flutter/material.dart';
import 'package:myapp/providers/MusicProvider/index.dart';
import 'package:myapp/providers/NavProvider/index.dart';
import 'package:myapp/providers/ThemeProvider/index.dart';
import 'package:myapp/providers/UserProvider/index.dart';
import 'package:myapp/router/IndexRouter/index.dart';
import 'package:myapp/service/Initialization/index.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await InitializationService.preRunInit();

  final initialSongs = await InitializationService.scanInitialMusic();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = MusicProvider();
            provider.initLibrary(initialSongs);
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
      ],
      child: const IndexRouter(),
    ),
  );
}
