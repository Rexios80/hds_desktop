import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart' as shelf_ws;
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel? client;

void main(List<String> arguments) async {
  final app = Router()
    ..put('/', handleHttpRequest)
    ..get('/', shelf_ws.webSocketHandler(handleWebSocketConnect));

  final server = await shelf_io.serve(app, '0.0.0.0', 3476);

  print('Serving at ${server.address.host}:${server.port}');
}

Future<Response> handleHttpRequest(Request request) async {
  final body = await request.readAsString();
  final json = jsonDecode(body);
  final data = json['data'];
  print('Received data: $data');
  client?.sink.add(data);
  return Response.ok(null);
}

void handleWebSocketConnect(WebSocketChannel socket) {
  client = socket;
  print('Client connected');
  socket.sink.done.then((e) => print('Client disconnected'));
}
