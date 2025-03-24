import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  static Future<MySqlConnection> connect() async {
    final settings = ConnectionSettings(
      host: '192.185.131.38',
      port: 3306,
      user: 'darkysfi_admin',
      password: 'Absolet1.',
      db: 'darkysfi_base2',
    );
    return await MySqlConnection.connect(settings);
  }
}
