import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart' as shelf_ws;
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel? overlay;
WebSocketChannel? watch;

void main(List<String> arguments) async {
  final app = Router()
    ..put('/', handleHttpRequest)
    ..get(
      '/',
      (request) => shelf_ws.webSocketHandler(
        (socket) => handleWebSocketConnect(request, socket),
      )(request),
    );

  final server = await shelf_io.serve(app, '0.0.0.0', 3476);
  print('Serving at on port ${server.port}');

  final interfaces =
      await NetworkInterface.list(type: InternetAddressType.IPv4);
  print('Possible IP addresses of this machine:');
  for (final interface in interfaces) {
    print(
      '  - ${interface.name}: ${interface.addresses.map((e) => e.address).join(', ')}',
    );
  }
}

Future<Response> handleHttpRequest(Request request) async {
  if (watch != null) {
    print('Error: Received HTTP request while watch socket is connected');
    return Response.ok(null);
  }

  final body = await request.readAsString();
  final json = jsonDecode(body);
  final data = json['data'];
  handleData(data);

  return Response.ok(null);
}

void handleWebSocketConnect(Request request, WebSocketChannel socket) async {
  final info =
      request.context['shelf.io.connection_info']! as HttpConnectionInfo;
  if (info.remoteAddress.host == '127.0.0.1') {
    await overlay?.sink.close();
    print('Overlay connected');
    overlay = socket;
    await socket.sink.done;
    print('Overlay disconnected');
    overlay = null;
  } else {
    await watch?.sink.close();
    print('Watch connected');
    watch = socket;
    socket.stream.listen((e) => handleData(e));
    await socket.sink.done;
    print('Watch disconnected');
    watch = null;
  }
}

void handleData(String data) {
  print('Received data: $data');

  if (overlay == null) {
    print('Error: Overlay not connected');
    return;
  }

  overlay?.sink.add(data);
}
