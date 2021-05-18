import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

enum Jaathi { thrishra, chaturashra, khanda, mishra, sankeerna }

enum SapthaTaala { dhruva, mathya, rupaka, jhumpa, triputa, atta, eka }

enum Anga { laghu, dhruta, anudhruta }

enum Comp { tap, flip, count1, count2, count3, count4, count5 }

class TaalaAnimation extends SimpleAnimation {
  TaalaAnimation(String animationName) : super(animationName);

  setState(TaalaData data) {
    instance.animation.fps = data.fps;
    instance.animation.speed = data.speed;
    isActive = false;
  }

  setSpeed(double speed) {
    instance.animation.speed = speed;
  }

  stop() {
    isActive = false;
    instance.reset();
  }

  start() {
    isActive = true;
  }
}

class Taala extends StatefulWidget {
  @override
  _TaalaState createState() => _TaalaState();
}

class _TaalaState extends State<Taala> {
  Artboard _riveArtboard;
  Map<Comp, TaalaAnimation> _animations = Map();

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
        // Add a controller to play back a known animation on the main/default
        // artboard.We store a reference to it so we can toggle playback.

        _animations[Comp.tap] = TaalaAnimation('Tap');
        _animations[Comp.flip] = TaalaAnimation('Flip');
        _animations[Comp.count1] = TaalaAnimation('Count1');
        _animations[Comp.count2] = TaalaAnimation('Count2');
        _animations[Comp.count3] = TaalaAnimation('Count3');
        _animations[Comp.count4] = TaalaAnimation('Count4');
        _animations[Comp.count5] = TaalaAnimation('Count5');

        _animations.forEach((key, value) => artboard.addController(value));
        setState(() => _riveArtboard = artboard);
      },
    );
  }

  void start(TaalaData data) {
    _animations.forEach((key, value) => value.setState(data));
    // _animations[data.playing].isActive = true;
  }

  @override
  Widget build(BuildContext context) {
    print("building");
    if (_riveArtboard == null)
      return Center(child: CircularProgressIndicator());
    else {
      start(TaalaInfo.of(context).taalaData);
      return Center(
        child: Rive(artboard: _riveArtboard),
      );
    }
  }
}

class TaalaInfo extends InheritedWidget {
  final TaalaData taalaData;
  TaalaInfo({Widget child, this.taalaData}) : super(child: child);
  @override
  bool updateShouldNotify(covariant TaalaInfo oldWidget) =>
      oldWidget.taalaData != taalaData;

  static TaalaInfo of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TaalaInfo>();
}

class TaalaData {
  int playingIndex;
  double speed;
  int fps;
  List<Comp> playSeq;
  TaalaData(
      {this.speed = 1,
      this.fps = 60,
      this.playingIndex = 0,
      this.playSeq});

  bool operator ==(covariant TaalaData data) {
    return data.speed == speed &&
        data.fps == fps;
  }

  @override
  int get hashCode => super.hashCode;
}

class TaalaNotifier extends ValueNotifier<TaalaData> {
  TaalaNotifier(TaalaData value) : super(value);
}

final List<Comp> aadiTaala = [
  Comp.tap,
  Comp.count1,
  Comp.count2,
  Comp.count3,
  Comp.tap,
  Comp.flip,
  Comp.tap,
  Comp.flip
];
