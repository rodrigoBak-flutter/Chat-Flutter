import 'dart:io';

class Environment {
  static String apiUrl = Platform.isAndroid
      ? 'https://chat-flutter-rodrigo.herokuapp.com/'
      : 'https://chat-flutter-rodrigo.herokuapp.com/';
  static String socketUrl = Platform.isAndroid
      ? 'https://chat-flutter-rodrigo.herokuapp.com/'
      : 'https://chat-flutter-rodrigo.herokuapp.com/';
}
