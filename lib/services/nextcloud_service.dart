import 'dart:convert';
import 'package:http/http.dart' as http;

class NextcloudService {
  static const _baseUrl = 'https://nextcloud.homecloudms.duckdns.org/remote.php/dav/files/MaksimSendetski/Apps/Nota';
  static const _username = 'MaksimSendetski';
  static const _fileName = 'nota_backup.json';

  final String _password;

  NextcloudService(this._password);

  String get _fileUrl => '$_baseUrl/$_fileName';

  Map<String, String> get _headers {
    final credentials = base64Encode(utf8.encode('$_username:$_password'));
    return {
      'Authorization': 'Basic $credentials',
      'Content-Type': 'application/json',
    };
  }

  Future<bool> upload(String jsonData) async {
    try {
      final response = await http.put(
        Uri.parse(_fileUrl),
        headers: _headers,
        body: jsonData,
      );
      return response.statusCode == 201 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<String?> download() async {
    try {
      final response = await http.get(
        Uri.parse(_fileUrl),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _headers,
      );
      return response.statusCode == 207 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}