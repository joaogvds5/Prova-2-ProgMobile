import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'models/veiculo_Model.dart';
import 'repositorio/authRepository.dart';
import 'repositorio/veiculoRepository.dart';
import 'repositorio/abastecimentoRepository.dart';
import 'viewmodels/authUser.dart';
import 'viewmodels/VeiculoViewModel.dart';
import 'viewmodels/AbastecimentoViewModel.dart';
import 'auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) =>
              AuthViewModel(authRepository: context.read<AuthRepository>()),
        ),

        Provider<VeiculoRepository>(create: (_) => VeiculoRepository()),
        ChangeNotifierProvider<VeiculoViewModel>(
          create: (context) =>
              VeiculoViewModel(repository: context.read<VeiculoRepository>()),
        ),
        StreamProvider<List<Veiculo>>(
          create: (context) => context.read<VeiculoRepository>().getVeiculo(),
          initialData: [],
          catchError: (_, error) => [],
        ),

        Provider<AbastecimentoRepository>(
          create: (_) => AbastecimentoRepository(),
        ),
        ChangeNotifierProvider<AbastecimentoViewmodel>(
          create: (context) => AbastecimentoViewmodel(
            repository: context.read<AbastecimentoRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trabalho André Prog Mobile',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],

      home: const AuthGate(),
    );
  }
}
