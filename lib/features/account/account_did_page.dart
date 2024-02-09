import 'package:flutter/material.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AccountDidPage extends HookConsumerWidget {
  const AccountDidPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final did = ref.watch(didProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My DID')),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Grid.side),
          child: Center(child: SelectableText(did.uri))),
    );
  }
}
