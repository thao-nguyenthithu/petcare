import 'dart:async';

import 'package:petcare_app/features/messaging/data/chat_message.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatSocketService {
  ChatSocketService({required String serverGoc, required String token})
    : _serverGoc = serverGoc,
      _token = token;

  final String _serverGoc;
  final String _token;

  io.Socket? _socket;
  String? _conversationId;

  final _tinMoiCtrl = StreamController<ChatMessage>.broadcast();
  final _daDocCtrl = StreamController<String>.broadcast();

  Stream<ChatMessage> get tinMoi => _tinMoiCtrl.stream;

  Stream<String> get daDoc => _daDocCtrl.stream;

  void ketNoi({required String conversationId}) {
    _conversationId = conversationId;
    final socket = io.io(
      '$_serverGoc/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': _token})
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      socket.emit('chat:join', {'conversationId': _conversationId});
    });
    socket.on('message:new', (data) {
      if (data is! Map) return;
      final tin = data['message'];
      if (tin is! Map) return;
      _bao(_tinMoiCtrl, ChatMessage.fromJson(Map<String, dynamic>.from(tin)));
    });
    socket.on('message:read', (data) {
      final id = data is Map ? data['userId'] : null;
      if (id is String) _bao(_daDocCtrl, id);
    });
    socket.connect();
  }

  void _bao<T>(StreamController<T> ctrl, T giaTri) {
    if (!ctrl.isClosed) ctrl.add(giaTri);
  }

  void dong() {
    final id = _conversationId;
    if (id != null) _socket?.emit('chat:leave', {'conversationId': id});
    _socket?.dispose();
    _socket = null;
    _tinMoiCtrl.close();
    _daDocCtrl.close();
  }
}
