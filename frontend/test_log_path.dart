import 'package:path_provider/path_provider.dart';

void main() async {
  final docDir = await getApplicationDocumentsDirectory();
  print('Documents directory: ${docDir.path}');
  print('Full logs path: ${docDir.path}/pet_care_logs');
}
