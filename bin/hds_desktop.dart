import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ansicolor/ansicolor.dart';
import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart' as shelf_ws;
import 'package:web_socket_channel/web_socket_channel.dart';

final magentaPen = AnsiPen()..magenta();
final greenPen = AnsiPen()..green();
final yellowPen = AnsiPen()..yellow();
final redPen = AnsiPen()..red();

WebSocketChannel? overlay;
WebSocketChannel? watch;

final parser = ArgParser()
  ..addOption(
    'port',
    abbr: 'p',
    defaultsTo: '3476',
  );

void main(List<String> arguments) async {
  print(
    yellowPen(
      'This desktop app supports one overlay connection and one watch connection at a time.'
      '\nOverlays must be running on this machine to work.'
      '\nFor more features such as simultaneous watch connections, please consider using HDS Cloud.'
      '\nTo run the server on a different port, use the --port flag.',
    ),
  );

  final args = parser.parse(arguments);
  final port = int.parse(args['port']!);

  final app = Router()
    ..put('/', handleHttpRequest)
    ..get(
      '/',
      (request) => shelf_ws.webSocketHandler(
        (socket) => handleWebSocketConnect(request, socket),
      )(request),
    );

  final server = await shelf_io.serve(app, '0.0.0.0', port);
  print('Serving on port ${server.port}');

  printIpAddresses();
}

void printIpAddresses() async {
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
    print(redPen('Received HTTP request while watch socket is connected'));
    return Response.ok(null);
  }

  final body = await request.readAsString();
  final json = jsonDecode(body);
  final data = json['data'];
  handleData(data);

  return Response.ok(null);
}

void handleWebSocketConnect(Request request, WebSocketChannel socket) {
  final info =
      request.context['shelf.io.connection_info']! as HttpConnectionInfo;
  if (info.remoteAddress.host == '127.0.0.1') {
    handleOverlayConnection(socket);
  } else {
    handleWatchConnection(socket);
  }
}

void handleOverlayConnection(WebSocketChannel socket) async {
  await overlay?.sink.close();
  print(greenPen('Overlay connected'));
  overlay = socket;
  await socket.sink.done;
  print(yellowPen('Overlay disconnected'));
  overlay = null;
}

void handleWatchConnection(WebSocketChannel socket) async {
  await watch?.sink.close();
  print(greenPen('Watch connected'));
  watch = socket;
  socket.stream.listen((e) => handleData(e));
  await socket.sink.done;
  print(yellowPen('Watch disconnected'));
  watch = null;
}

void handleData(String data) {
  print('Received data: $data');

  if (overlay == null) {
    print(redPen('Overlay not connected'));
    return;
  }

  overlay?.sink.add(data);
}
