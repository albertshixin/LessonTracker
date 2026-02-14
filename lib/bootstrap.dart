import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'app_config.dart';

Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ipgpfursfnkwlomqvxxj.supabase.co',
    anonKey: 'sb_publishable_cx3QorGBrCVcnkpQRw7rIA_4tDeU0zC',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  try {
    await Supabase.instance.client.auth.getSessionFromUrl(Uri.base);
  } catch (_) {
    // Ignore if there is no auth code in the URL.
  }

  final config = AppConfig.forFlavor(flavor);
  runApp(App(config: config));
}
