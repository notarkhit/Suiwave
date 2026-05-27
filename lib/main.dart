import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// Native setlocale for Linux locale fix required by media_kit
typedef SetlocaleCFunc = Pointer<Char> Function(Int32, Pointer<Char>);
typedef SetlocaleFunc = Pointer<Char> Function(int, Pointer<Char>);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // media_kit requires the C numeric locale on Linux
  if (Platform.isLinux) {
    final libc = DynamicLibrary.open('libc.so.6');
    final setlocale = libc.lookupFunction<SetlocaleCFunc, SetlocaleFunc>('setlocale');
    final cLocale = malloc.allocate<Char>(2);
    cLocale[0] = 0x43; // 'C'
    cLocale[1] = 0x00; // null terminator
    setlocale(1, cLocale);
    malloc.free(cLocale);
  }

  // Initialize media_kit (required before any Player is created)
  MediaKit.ensureInitialized();

  // Prefer edge-to-edge on Android
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  runApp(const ProviderScope(child: SuiwaveApp()));
}

class SuiwaveApp extends StatelessWidget {
  const SuiwaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Suiwave',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.darkTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.dark,
    );
  }
}
