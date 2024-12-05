import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;

class GameScreen extends StatefulWidget {
  @override
  _GameScreenWebState createState() => _GameScreenWebState();
}

class _GameScreenWebState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    // Register an HTML view for the iframe
    final String viewID = 'game-iframe';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewID, (int viewId) {
      return html.IFrameElement()
        ..src = 'https://nyan.kunststaub.fm/'
        ..style.border = 'none'
        ..width = '100%'
        ..height = '600px';
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Kunststaub FM Game"),
      ),
      body: HtmlElementView(
        viewType: viewID,
      ),
    );
  }
}
