import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/shared_prefs_service.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authState = ref.read(authControllerProvider);
      if (authState is AuthInitial) {
        final userId = await InjectionContainer.get<IAuthStorageService>().getUserId();
        await ref.read(authControllerProvider.notifier).getCandidateData(userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(child: Text(ref.watch(authControllerProvider).toString())),
    );
  }
}
