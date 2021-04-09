import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:chat/global/environment.dart';
import 'package:chat/models/login_response.dart';
import 'package:flutter/foundation.dart';
import 'package:chat/models/usuario.dart';

class AuthService with ChangeNotifier {
  Usuario usuario;
  bool _autenticando = false;

  final _storage = new FlutterSecureStorage();

  bool get autenticando => this._autenticando;
  set autenticando(bool valor) {
    this._autenticando = valor;
    notifyListeners();
  }

  //Getter del token de forma estatica
  static Future<String> getToken() async {
    final _storage = new FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    final _storage = new FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  Future<bool> login(String email, String password) async {
    this.autenticando = true;
    final data = {
      //ACA recibo de la api la informacion que quiero
      'email': email,
      'password': password
    };

    final resp = await http.post(
      '${Environment.apiUrl}/login',
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    // print(resp.body);
    this.autenticando = false;

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;
      //TODO: Guardar token en logar seguro
      await this._guardarToken(loginResponse.token);
      return true;
    } else {
      return false;
    }
  }

  Future register(String nombre, String email, String password) async {
    this.autenticando = true;
    final data = {
      //ACA recibo de la api la informacion que quiero
      'nombre': nombre,
      'email': email,
      'password': password
    };

    final resp = await http.post(
      '${Environment.apiUrl}/login/new',
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    // print(resp.body);
    this.autenticando = false;

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;
      //TODO: Guardar token en logar seguro
      await this._guardarToken(loginResponse.token);
      return true;
    } else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  Future _guardarToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future isLoginIn() async {
    final token = await this._storage.read(key: 'token');
    print(token);
    final resp = await http.get(
      '${Environment.apiUrl}/login/renew',
      headers: {'Content-Type': 'application/json', 'xtoken': token},
    );

    // print(resp.body);

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      this.usuario = loginResponse.usuario;
      //TODO: Guardar token en lugar seguro
      await this._guardarToken(loginResponse.token);
      return true;
    } else {
      this.logout();
      return false;
    }
  }

  Future logout() async {
    await _storage.delete(key: 'token');
  }
}
