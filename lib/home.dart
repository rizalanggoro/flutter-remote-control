import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:remote_control/socket.dart';
import 'package:remote_control/utils.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<Home> {
  final Socket _socket = Socket();
  late Utils _utils;
  final ValueNotifier<bool> _valueNotifierSocketConnected =
      ValueNotifier(false);
  final ValueNotifier<int> _valueNotifierConnection = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    _utils = Utils(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(child: _body),
    );
  }

  get _body {
    return Row(
      children: [
        ValueListenableBuilder(
            valueListenable: _valueNotifierSocketConnected,
            builder: (context, bool value, child) => _motorB),
        _action,
        ValueListenableBuilder(
            valueListenable: _valueNotifierSocketConnected,
            builder: (context, bool value, child) => _motorA),
      ],
    );
  }

  get _action {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.only(left: 32, right: 32),
      child: ValueListenableBuilder(
          valueListenable: _valueNotifierConnection,
          builder: (context, value, child) => FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var mapData = snapshot.data as Map<String, String>;
                    var gateway = mapData['gateway'] ?? '0.0.0.0';
                    // var name = mapData['name'] ?? 'null';

                    if (gateway != '0.0.0.0') {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            gateway,
                            style: TextStyle(
                                color: Colors.white.withOpacity(.64),
                                fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ws://$gateway/ws',
                            style: TextStyle(
                                color: Colors.white.withOpacity(.64),
                                fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                              onPressed: () {
                                _valueNotifierConnection.value++;
                              },
                              child: const Text('Muat ulang')),
                          ValueListenableBuilder(
                              valueListenable: _valueNotifierSocketConnected,
                              builder: (context, bool value, child) =>
                                  ElevatedButton(
                                      onPressed: () {
                                        if (value) {
                                          _socket.closeChannel();
                                          _valueNotifierSocketConnected.value =
                                              false;
                                        } else {
                                          _openSocketConnection(gateway);
                                        }
                                      },
                                      child: Text(
                                          value ? 'Putuskan' : 'Hubungkan'))),
                        ],
                      );
                    }
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Koneksi tidak ditemukan. '
                        'Pastikan WiFi ponsel terhubung dengan WiFi RC.',
                        style: TextStyle(
                            color: Colors.white.withOpacity(.64), fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: () {
                            _valueNotifierConnection.value++;
                          },
                          child: const Text('Muat ulang')),
                    ],
                  );
                },
                future: _actionGetWifiInfo(),
              )),
    ));
  }

  void _openSocketConnection(gateway) {
    _socket.openChannel('ws://$gateway/ws');
    _socket.stream.listen((data) {
      if (data == 'ok') {
        _valueNotifierSocketConnected.value = true;
      }
    }, onError: (error) {
      _socket.closeChannel();
      _valueNotifierSocketConnected.value = false;
    });
  }

  Future<Map<String, String>> _actionGetWifiInfo() async {
    final info = NetworkInfo();

    Map<String, String> data = {};
    data['gateway'] = await info.getWifiGatewayIP() ?? '0.0.0.0';
    // data['name'] = await info.getWifiName() ?? 'null';

    return data;
  }

  get _motorB {
    var en = _valueNotifierSocketConnected.value;

    return Container(
        margin: const EdgeInsets.only(left: 32),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _controllerButton(
                  enable: en,
                  iconData: Icons.arrow_upward_rounded,
                  onDown: (details) {
                    _socket.sendMessage('b:f');
                  },
                  onUp: (details) {
                    _socket.sendMessage('b:0');
                  }),
              const SizedBox(height: 8),
              _controllerButton(
                  enable: en,
                  iconData: Icons.arrow_downward_rounded,
                  onDown: (details) {
                    _socket.sendMessage('b:b');
                  },
                  onUp: (details) {
                    _socket.sendMessage('b:0');
                  }),
            ]));
  }

  get _motorA {
    var en = _valueNotifierSocketConnected.value;

    return Container(
        margin: const EdgeInsets.only(right: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                _actionButton(
                    enable: en,
                    iconData: Icons.volume_up_rounded,
                    onDown: (details) {
                      _socket.sendMessage('h:1');
                    },
                    onUp: (details) {
                      _socket.sendMessage('h:0');
                    }),
                const SizedBox(width: 8),
                _actionButton(
                    enable: en,
                    iconData: Icons.lightbulb_rounded,
                    onDown: (details) {
                      _socket.sendMessage('l:1');
                    }),
                const SizedBox(width: 8),
                _actionButton(
                    enable: en,
                    iconData: Icons.lightbulb_outline_rounded,
                    onDown: (details) {
                      _socket.sendMessage('l:0');
                    }),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              _controllerButton(
                  enable: en,
                  iconData: Icons.arrow_back_rounded,
                  onDown: (details) {
                    _socket.sendMessage('a:l');
                  },
                  onUp: (details) {
                    _socket.sendMessage('a:0');
                  }),
              const SizedBox(width: 8),
              _controllerButton(
                  enable: en,
                  iconData: Icons.arrow_forward_rounded,
                  onDown: (details) {
                    _socket.sendMessage('a:r');
                  },
                  onUp: (details) {
                    _socket.sendMessage('a:0');
                  }),
            ])
          ],
        ));
  }

  _actionButton({
    required IconData iconData,
    Function(TapUpDetails)? onUp,
    Function(TapDownDetails)? onDown,
    bool? enable,
  }) {
    int count = 3;
    double parentWidth = ((_utils.height(28) * 2) + 8);
    double tileSize = ((parentWidth - (8 * (count - 1))) / count);
    bool en = (enable ?? false);

    return GestureDetector(
      onTapUp: en ? onUp : null,
      onTapDown: en ? onDown : null,
      child: Container(
        decoration: BoxDecoration(
            color: en ? Colors.grey.shade800 : Colors.grey.shade900,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: en
                ? null
                : Border.all(width: 2.4, color: Colors.grey.shade800)),
        height: tileSize,
        width: tileSize,
        child: Icon(
          iconData,
          color: en ? Colors.white : Colors.grey.shade800,
          size: (tileSize / 3),
        ),
      ),
    );
  }

  _controllerButton({
    required IconData iconData,
    Function(TapUpDetails)? onUp,
    Function(TapDownDetails)? onDown,
    bool? enable,
  }) {
    double size = 28;
    bool en = (enable ?? false);

    return GestureDetector(
      onTapUp: en ? onUp : null,
      onTapDown: en ? onDown : null,
      child: Container(
        decoration: BoxDecoration(
            color: en ? Colors.grey.shade800 : Colors.grey.shade900,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: en
                ? null
                : Border.all(width: 2.4, color: Colors.grey.shade800)),
        height: _utils.height(size),
        width: _utils.height(size),
        child: Icon(
          iconData,
          color: en ? Colors.white : Colors.grey.shade800,
          size: _utils.height(size / 3),
        ),
      ),
    );
  }
}
