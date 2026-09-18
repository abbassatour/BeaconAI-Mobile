import 'package:beacon_ai/app/app.dart';
import 'package:beacon_ai/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
