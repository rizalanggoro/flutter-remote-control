import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Socket {
  late WebSocketChannel _channel;
  void openChannel(String url) {
    _channel = IOWebSocketChannel.connect(url);
    _sendDefaultState();
  }

  Stream get stream => _channel.stream;

  void _sendDefaultState() {
    sendMessage('a:0');
    sendMessage('b:0');
    sendMessage('s:255');
  }

  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  void closeChannel() {
    _channel.sink.close();
  }
}
