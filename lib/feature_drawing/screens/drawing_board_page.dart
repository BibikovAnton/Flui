import 'package:Flui/feature_chat/screens/chat_page.dart';
import 'package:Flui/feature_drawing/data/models/drawing_data.dart';
import 'package:Flui/feature_drawing/widgets/drawer_painter.dart';
import 'package:Flui/services/drawing_service.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

final drawingPointsProvider = StreamProvider.family<List<DrawingPoint>, String>(
  (ref, receiverId) {
    return ref.read(firestoreServiceProvider).getDrawingPoints(receiverId);
  },
);

final drawingToolsProvider =
    StateNotifierProvider<DrawingToolsNotifier, DrawingToolsState>((ref) {
      return DrawingToolsNotifier();
    });

class DrawingToolsState {
  final Color selectedColor;
  final double strokeWidth;
  final bool isErasing;
  final bool showTools;

  DrawingToolsState({
    this.selectedColor = Colors.black,
    this.strokeWidth = 3.0,
    this.isErasing = false,
    this.showTools = true,
  });

  DrawingToolsState copyWith({
    Color? selectedColor,
    double? strokeWidth,
    bool? isErasing,
    bool? showTools,
  }) {
    return DrawingToolsState(
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isErasing: isErasing ?? this.isErasing,
      showTools: showTools ?? this.showTools,
    );
  }
}

class DrawingToolsNotifier extends StateNotifier<DrawingToolsState> {
  DrawingToolsNotifier() : super(DrawingToolsState());

  void changeColor(Color color) {
    state = state.copyWith(selectedColor: color, isErasing: false);
  }

  void changeStrokeWidth(double width) {
    state = state.copyWith(strokeWidth: width);
  }

  void toggleEraser() {
    state = state.copyWith(
      isErasing: !state.isErasing,
      selectedColor: !state.isErasing ? Colors.white : Colors.black,
    );
  }

  void toggleToolsVisibility() {
    state = state.copyWith(showTools: !state.showTools);
  }
}

class DrawingScreen extends ConsumerStatefulWidget {
  final String receiverId;

  const DrawingScreen({super.key, required this.receiverId});

  @override
  ConsumerState<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends ConsumerState<DrawingScreen> {
  final List<List<DrawingPoint>> _history = [];
  final List<List<DrawingPoint>> _redoHistory = [];
  String _currentStrokeId = '';
  bool _isDrawing = false;

  Future<void> _undoLastAction(List<DrawingPoint> points) async {
    if (points.isEmpty) return;

    final lastStrokeId = points.last.strokeId;
    _redoHistory.add(List.from(points));

    final newPoints =
        points.where((point) => point.strokeId != lastStrokeId).toList();
    await ref
        .read(firestoreServiceProvider)
        .updateAllPoints(newPoints, widget.receiverId);
  }

  Future<void> _redoLastAction(List<DrawingPoint> points) async {
    if (_redoHistory.isEmpty) return;

    _history.add(List.from(points));
    final redonePoints = _redoHistory.removeLast();
    await ref
        .read(firestoreServiceProvider)
        .updateAllPoints(redonePoints, widget.receiverId);
  }

  Future<void> _clearDrawing() async {
    final points =
        ref.read(drawingPointsProvider(widget.receiverId)).value ?? [];
    _history.add(List.from(points));
    _redoHistory.clear();
    await ref.read(firestoreServiceProvider).clearCanvas(widget.receiverId);
  }

  Future<void> _handleDrawingStart(DragStartDetails details) async {
    final tools = ref.read(drawingToolsProvider.notifier);
    final currentUser = FirebaseAuth.instance.currentUser;
    final points =
        ref.read(drawingPointsProvider(widget.receiverId)).value ?? [];

    _currentStrokeId = DateTime.now().millisecondsSinceEpoch.toString();
    _history.add(List.from(points));
    _redoHistory.clear();

    final point = DrawingPoint(
      offset: details.localPosition,
      color: tools.state.isErasing ? Colors.white : tools.state.selectedColor,
      strokeWidth:
          tools.state.isErasing
              ? tools.state.strokeWidth * 2
              : tools.state.strokeWidth,
      userId: currentUser?.uid ?? '',
      strokeId: _currentStrokeId,
      receiverId: widget.receiverId,
    );

    setState(() => _isDrawing = true);
    await ref
        .read(firestoreServiceProvider)
        .sendDrawingPoint(point, widget.receiverId);
  }

  Future<void> _handleDrawingUpdate(DragUpdateDetails details) async {
    if (!_isDrawing) return;

    final tools = ref.read(drawingToolsProvider.notifier);
    final currentUser = FirebaseAuth.instance.currentUser;

    final point = DrawingPoint(
      offset: details.localPosition,
      color: tools.state.isErasing ? Colors.white : tools.state.selectedColor,
      strokeWidth:
          tools.state.isErasing
              ? tools.state.strokeWidth * 2
              : tools.state.strokeWidth,
      userId: currentUser?.uid ?? '',
      strokeId: _currentStrokeId,
      receiverId: widget.receiverId,
    );

    await ref
        .read(firestoreServiceProvider)
        .sendDrawingPoint(point, widget.receiverId);
  }

  void _handleDrawingEnd(DragEndDetails details) {
    setState(() => _isDrawing = false);
  }

  void _openColorPicker(BuildContext context) {
    final tools = ref.read(drawingToolsProvider.notifier);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Выберите цвет'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: tools.state.selectedColor,
                onColorChanged: tools.changeColor,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Готово'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawingPoints = ref.watch(drawingPointsProvider(widget.receiverId));
    final tools = ref.watch(drawingToolsProvider.notifier);
    final toolsState = ref.watch(drawingToolsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Рисовалка'),
        actions: [
          IconButton(
            icon: Icon(
              toolsState.showTools ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: tools.toggleToolsVisibility,
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () => _undoLastAction(drawingPoints.value ?? []),
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () => _redoLastAction(drawingPoints.value ?? []),
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _clearDrawing),
          IconButton(
            icon: Icon(
              toolsState.isErasing
                  ? Icons.brush
                  : Icons.cleaning_services_outlined,
            ),
            onPressed: tools.toggleEraser,
          ),
        ],
      ),
      body: Stack(
        children: [
          drawingPoints.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Ошибка: $error')),
            data:
                (points) => GestureDetector(
                  onPanStart: _handleDrawingStart,
                  onPanUpdate: _handleDrawingUpdate,
                  onPanEnd: _handleDrawingEnd,
                  child: CustomPaint(
                    painter: DrawingPainter(points: points),
                    size: Size.infinite,
                  ),
                ),
          ),

          if (toolsState.showTools)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                margin: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () => _openColorPicker(context),
                          child: const Icon(Icons.color_lens),
                        ),
                        Slider(
                          value: toolsState.strokeWidth,
                          min: 1,
                          max: 20,
                          onChanged: tools.changeStrokeWidth,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          SlidingUpPanel(
            minHeight: 60,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            panel: ChatPage(
              receiverEmail: FirebaseAuth.instance.currentUser?.uid ?? '',
              receiverId: widget.receiverId,
            ),
            collapsed: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Icon(Icons.keyboard_arrow_up, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
