import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://nyan.kunststaub.fm/'));
  }

  void _sendKeyEvent(String key) {
    String script = '''
      document.dispatchEvent(new KeyboardEvent('keydown', {
        key: '$key',
        keyCode: ${_getKeyCode(key)},
        bubbles: true,
        cancelable: true
      }));
    ''';

    _controller.runJavaScript(script);
  }

  int _getKeyCode(String key) {
    switch (key) {
      case 'ArrowUp':
        return 38;
      case 'ArrowDown':
        return 40;
      case 'ArrowLeft':
        return 37;
      case 'ArrowRight':
        return 39;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kunststaub FM Game"),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_upward),
                      onPressed: () => _sendKeyEvent('ArrowUp'),
                      iconSize: 48,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => _sendKeyEvent('ArrowLeft'),
                          iconSize: 48,
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () => _sendKeyEvent('ArrowRight'),
                          iconSize: 48,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_downward),
                      onPressed: () => _sendKeyEvent('ArrowDown'),
                      iconSize: 48,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
