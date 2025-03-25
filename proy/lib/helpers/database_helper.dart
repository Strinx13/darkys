import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  static Future<MySqlConnection> connect() async {
    final settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',
      password: '',
      db: 'darkys',
    );

    return await MySqlConnection.connect(settings);
  }
}
