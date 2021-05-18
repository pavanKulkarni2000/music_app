import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart';

/// An example showing how to drive a StateMachine via one numeric input.
class StateMachineSkills extends StatefulWidget {
  @override
  _StateMachineSkillsState createState() => _StateMachineSkillsState();
}

class _StateMachineSkillsState extends State<StateMachineSkills> {
  /// Tracks if the animation is playing by whether controller is running.
  bool get isPlaying => _controller?.isActive ?? false;

  List<int> lis = [0, 1, 0, 2, 3, 4];
  int currentlyPlayingIndex = 0;
  Timer _timer;

  Artboard _riveArtboard;
  StateMachineController _controller;
  SMINumber _boolInput;

  _toggle() {
    if (_timer.isActive)
      _timer.cancel();
    else
      _timer = new Timer.periodic(Duration(seconds: 1), (timer) => next());
    setState(() {
      _controller.isActive = !_controller.isActive;
    });
    print(_controller.isActive);
  }

  void next() {
    currentlyPlayingIndex = (currentlyPlayingIndex + 1) % lis.length;
    setState(() {
      _boolInput.value = lis[currentlyPlayingIndex] as double;
    });
  }

  @override
  void initState() {
    super.initState();

    // Load the animation file from the bundle, note that you could also
    // download this. The RiveFile just expects a list of bytes.
    rootBundle.load('assets/Hand7.riv').then(
      (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        _controller = StateMachineController.fromArtboard(artboard, 'Seq');
        if (_controller != null) {
          artboard.addController(_controller);
          _boolInput = _controller.findInput<double>('gate');
          _boolInput.value = 0;
          _timer =
              new Timer.periodic(Duration(seconds: 1), (Timer timer) => next());
        }
        setState(() => _riveArtboard = artboard);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Skills Machine'),
      ),
      body: Center(
        child: _riveArtboard == null
            ? const SizedBox()
            : Center(
                child: Rive(
                  artboard: _riveArtboard,
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggle,
        tooltip: isPlaying ? 'Pause' : 'Play',
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
