import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/taala.dart';
import 'package:rive/rive.dart';
import 'components.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TaalaData _taala;
  Timer _timer;
  Artboard _riveArtboard;
  Map<Comp, TaalaAnimation> _animations = Map();
  Stopwatch _watch;
  bool isPlaying;
  SliderData _sliderData;

  _toggle() {
    isPlaying = !isPlaying;
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _watch.stop();
    } else
      resetTimer();

    var _controller = getCurrentController();
    setState(() {
      _controller.isActive = !_controller.isActive;
    });
  }

  _sliderChanged(double newValue) {
    setState(() {
      _sliderData.value = newValue;
    });
    setTaalaSpeed(newValue);
  }

  @override
  void initState() {
    super.initState();

    _taala = TaalaData(playSeq: aadiTaala);
    _sliderData = SliderData(min: 0.02, max: 4, value: 1);
    _watch = Stopwatch();
    isPlaying = false;
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

        _animations = {
          Comp.tap: TaalaAnimation('Tap'),
          Comp.flip: TaalaAnimation('Flip'),
          Comp.count1: TaalaAnimation('Count1'),
          Comp.count2: TaalaAnimation('Count2'),
          Comp.count3: TaalaAnimation('Count3'),
          Comp.count4: TaalaAnimation('Count4'),
          Comp.count5: TaalaAnimation('Count5')
        };

        _animations.forEach((key, value) => artboard.addController(value));
        setState(() => {_riveArtboard = artboard, setTaalaState()});
      },
    );
  }

  setTaalaState() {
    _animations.forEach((key, value) => value.setState(_taala));
    getCurrentController().isActive = isPlaying;
    if (isPlaying) setTimer();
  }

  setTaalaSpeed(double speed) {
    _taala.speed = speed;
    _animations.forEach((key, value) => value.setSpeed(speed));
    if (isPlaying) {
      _timer.cancel();
      resetTimer();
    }
  }

  setTimer() {
    _watch.reset();
    _timer = Timer.periodic(
        Duration(milliseconds: ( 1000 / _taala.speed).round()),
        (timer) => setNextTaalaState());
    _watch.start();
  }

  resetTimer() {
    _timer = Timer(
        Duration(
            milliseconds:
                ((1000 - _watch.elapsedMilliseconds) / _taala.speed).round()),
        () => {
              setNextTaalaState(),
              _timer = Timer.periodic(
                  Duration(
                      milliseconds:
                          ( 1000 / _taala.speed).round()),
                  (timer) => setNextTaalaState())
            });
    _watch.start();
  }

  setNextTaalaState() {
    print(_taala.playingIndex);
    getCurrentController().stop();
    _watch.reset();
    incrementTaala();
    getCurrentController().start();
    _watch.start();
  }

  getCurrentController() {
    var cur = _animations[_taala.playSeq[_taala.playingIndex]];
    if (cur == null) print("returning null");
    return cur;
  }

  incrementTaala() {
    _taala.playingIndex = (_taala.playingIndex + 1) % _taala.playSeq.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_riveArtboard == null)
      return Center(child: CircularProgressIndicator());
    return Scaffold(
      body: Stack(children: [
        Center(
          child: Rive(artboard: _riveArtboard),
        ),
        Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Row(children: [
            SizedBox(
              width: 8,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(36, 36), shape: CircleBorder()),
              onPressed: _sliderData.disableDecrease()
                  ? null
                  : () => _sliderChanged(_sliderData.value / 2),
              child: Text("/"),
            ),
            SizedBox(
              width: 8,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(36, 36), shape: CircleBorder()),
              onPressed: _sliderData.disableDecrease()
                  ? null
                  : () => _sliderChanged(_sliderData.value - 0.2),
              child: Text("-"),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: CustomSliderThumb(
                      thumbRadius: 16,
                      min: _sliderData.min,
                      max: _sliderData.max),
                  // overlayShape: CustomSliderThumbOverlay(thumbRadius: 20)
                ),
                child: Slider(
                  value: _sliderData.value,
                  min: _sliderData.min,
                  max: _sliderData.max,
                  onChanged: _sliderChanged,
                  autofocus: false,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(36, 36), shape: CircleBorder()),
              onPressed: _sliderData.disableIncrease()
                  ? null
                  : () => _sliderChanged(_sliderData.value + 0.2),
              child: Text("+"),
            ),
            SizedBox(
              width: 8,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(36, 36), shape: CircleBorder()),
              onPressed: _sliderData.disableIncrease()
                  ? null
                  : () => _sliderChanged(_sliderData.value * 2),
              child: Text("x"),
            ),
            SizedBox(
              width: 8,
            ),
          ]),
          Row(children: [
            
          ],)
        ]),
      ],
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
