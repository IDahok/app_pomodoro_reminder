import 'package:flutter/material.dart';

class PomodoroTimer extends StatefulWidget {
  final int initialMinutes;
  final VoidCallback? onFinish;

  const PomodoroTimer({
    super.key,
    this.initialMinutes = 25,
    this.onFinish,
  });

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  late int _secondsLeft;
  bool _isRunning = false;
  late int _totalSeconds;
  late Duration _duration;
  late Duration _initialDuration;
  late Ticker _ticker;
  DateTime? _startTime;
  Duration _elapsedBeforePause = Duration.zero;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.initialMinutes * 60;
    _secondsLeft = _totalSeconds;
    _duration = Duration(seconds: _secondsLeft);
    _initialDuration = Duration(seconds: _totalSeconds);
  }

  @override
  void didUpdateWidget(covariant PomodoroTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMinutes != oldWidget.initialMinutes) {
      setState(() {
        _totalSeconds = widget.initialMinutes * 60;
        _secondsLeft = _totalSeconds;
        _duration = Duration(seconds: _secondsLeft);
        _initialDuration = Duration(seconds: _totalSeconds);
        _isRunning = false;
        _elapsedBeforePause = Duration.zero;
        _startTime = null;
      });
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _startTime = DateTime.now();
    });
    _ticker = Ticker(_onTick)..start();
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      if (_startTime != null) {
        _elapsedBeforePause += DateTime.now().difference(_startTime!);
      }
    });
    _ticker.dispose();
    _startTime = null;
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _secondsLeft = _totalSeconds;
      _duration = Duration(seconds: _secondsLeft);
      _elapsedBeforePause = Duration.zero;
      _startTime = null;
    });
    _ticker.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!_isRunning || _startTime == null) return;
    final now = DateTime.now();
    final totalElapsed = _elapsedBeforePause + now.difference(_startTime!);
    final secondsLeft = _totalSeconds - totalElapsed.inSeconds;
    setState(() {
      _secondsLeft = secondsLeft > 0 ? secondsLeft : 0;
      _duration = Duration(seconds: _secondsLeft);
      if (_secondsLeft <= 0) {
        _isRunning = false;
        _ticker.dispose();
        widget.onFinish?.call();
      }
    });
  }

  @override
  void dispose() {
    if (_isRunning) {
      _ticker.dispose();
    }
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatDuration(_duration),
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isRunning ? _pauseTimer : _startTimer,
              child: Text(_isRunning ? 'Pausar' : 'Iniciar'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _resetTimer,
              child: const Text('Resetar'),
            ),
          ],
        ),
      ],
    );
  }
}

// Classe Ticker simples para simular o Ticker do Flutter (sem dependências externas)
class Ticker {
  final void Function(Duration) onTick;
  late final Stopwatch _stopwatch;
  late final Duration _interval;
  bool _active = false;
  Duration get elapsed => _stopwatch.elapsed;

  Ticker(this.onTick, {Duration interval = const Duration(seconds: 1)}) {
    _interval = interval;
    _stopwatch = Stopwatch();
  }

  void start() async {
    _active = true;
    _stopwatch.start();
    while (_active) {
      await Future.delayed(_interval);
      if (!_active) break;
      onTick(_stopwatch.elapsed);
    }
  }

  void dispose() {
    _active = false;
    _stopwatch.stop();
    _stopwatch.reset();
  }
} 