import 'dart:async';

import 'package:chatty/services/drawing_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../models/drawing_data.dart';

class DrawingScreen extends StatefulWidget {
  final String roomId;
  final String userId;

  const DrawingScreen({required this.roomId, required this.userId, Key? key})
    : super(key: key);

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _chatController = TextEditingController();

  List<DrawingPoint> _points = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;
  bool _isErasing = false;
  bool _showChatPanel = false;
  bool _showToolsPanel = true;
  Offset _toolsPanelPosition = Offset(20, 100);
  List<ChatMessage> _chatMessages = [];

  late StreamSubscription<List<DrawingPoint>> _drawingSubscription;
  late StreamSubscription<List<ChatMessage>> _chatSubscription;

  @override
  void initState() {
    super.initState();
    _setupFirestoreListeners();
  }

  void _setupFirestoreListeners() {
    _drawingSubscription = _firestoreService
        .getDrawingPoints(widget.roomId)
        .listen((points) => setState(() => _points = points));

    _chatSubscription = _firestoreService
        .getChatMessages(widget.roomId)
        .listen((messages) => setState(() => _chatMessages = messages));
  }

  @override
  void dispose() {
    _drawingSubscription.cancel();
    _chatSubscription.cancel();
    _chatController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _addPoint(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _addPoint(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    // Можно добавить логику для завершения линии
  }

  void _addPoint(Offset offset) {
    final point = DrawingPoint(
      offset: offset,
      color: _isErasing ? Colors.white : _selectedColor,
      strokeWidth: _strokeWidth,
      isErase: _isErasing,
      userId: widget.userId,
    );

    _firestoreService.sendDrawingPoint(point, widget.roomId);
  }

  void _clearCanvas() {
    _firestoreService.clearCanvas(widget.roomId);
  }

  void _sendChatMessage() {
    if (_chatController.text.trim().isNotEmpty) {
      _firestoreService.sendChatMessage(
        widget.roomId,
        _chatController.text,
        widget.userId,
      );
      _chatController.clear();
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Выберите цвет'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: _selectedColor,
                onColorChanged:
                    (color) => setState(() => _selectedColor = color),
                showLabel: true,
                pickerAreaHeightPercent: 0.7,
              ),
            ),
            actions: [
              TextButton(
                child: Text('Готово'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Онлайн рисовалка'),
        actions: [
          IconButton(
            icon: Icon(_showChatPanel ? Icons.chat : Icons.chat_bubble_outline),
            onPressed: () => setState(() => _showChatPanel = !_showChatPanel),
          ),
          IconButton(icon: Icon(Icons.delete), onPressed: _clearCanvas),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: CustomPaint(
              painter: DrawingPainter(_points),
              size: Size.infinite,
            ),
          ),

          if (_showChatPanel)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 300,
              child: Container(
                color: Colors.white.withOpacity(0.9),
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _chatMessages.length,
                        itemBuilder: (context, index) {
                          final message = _chatMessages[index];
                          return ListTile(title: Text(message.text));
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            decoration: InputDecoration(
                              hintText: 'Введите сообщение...',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: _sendChatMessage,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          if (_showToolsPanel)
            Positioned(
              left: _toolsPanelPosition.dx,
              top: _toolsPanelPosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _toolsPanelPosition += Offset(
                      details.delta.dx,
                      details.delta.dy,
                    );
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.color_lens, color: _selectedColor),
                        onPressed: _showColorPicker,
                      ),
                      Slider(
                        value: _strokeWidth,
                        min: 1,
                        max: 30,
                        onChanged:
                            (value) => setState(() => _strokeWidth = value),
                      ),
                      IconButton(
                        icon: Icon(Icons.cleaning_services),
                        color: _isErasing ? Colors.red : Colors.grey,
                        onPressed:
                            () => setState(() => _isErasing = !_isErasing),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      if (current.isErase) {
        final paint =
            Paint()
              ..color = Colors.transparent
              ..strokeWidth = current.strokeWidth
              ..blendMode = BlendMode.clear
              ..strokeCap = StrokeCap.round;

        canvas.drawLine(current.offset, next.offset, paint);
      } else {
        final paint =
            Paint()
              ..color = current.color
              ..strokeWidth = current.strokeWidth
              ..strokeCap = StrokeCap.round;

        canvas.drawLine(current.offset, next.offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
