import 'package:music_app/languageUtils.dart';
import 'package:music_app/taala.dart';
import 'package:music_app/slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
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
  TaalaData taala;
  Timer timer;
  Artboard riveArtboard;
  Map<TaalaStep, TaalaAnimation> animations = Map();
  Stopwatch watch;
  bool isPlaying;
  SliderData sliderData;
  TaalaSelectionData taalaSelectionData;
  JaathiSelectionData jaathiSelectionData;

  setTimer() {
    watch.reset();
    timer?.cancel();
    timer = Timer.periodic(getTaalaDuration(), (t) => setNextTaalaState());
    watch.start();
  }

  resetTimer() {
    timer = Timer(getTaalaDuration(), () {
      setNextTaalaState();
      timer = Timer.periodic(getTaalaDuration(), (t) => setNextTaalaState());
    });
    watch.start();
  }

  getTaalaDuration() {
    return Duration(
        milliseconds:
            (1000 ~/ taala.speed - watch.elapsedMilliseconds).round());
  }

  togglePlaying() {
    isPlaying = !isPlaying;
    if (timer != null && timer.isActive) {
      timer.cancel();
      watch.stop();
    } else
      resetTimer();

    var controller = getCurrentController();
    setState(() {
      controller.isActive = !controller.isActive;
    });
  }

  sliderChanged(double newValue) {
    setState(() {
      sliderData.value = newValue;
    });
    setTaalaSpeed(newValue);
  }

  initializeTaalaState() {
    animations.forEach((key, value) => value.setState(taala));
    getCurrentController().isActive = isPlaying;
    if (isPlaying) setTimer();
  }

  setTaalaSpeed(double speed) {
    taala.speed = speed;
    animations.forEach((key, value) => value.setSpeed(speed));
    if (isPlaying) {
      timer.cancel();
      resetTimer();
    }
  }

  setNextTaalaState() {
    print(taala.playingIndex);
    watch.reset();
    getCurrentController().stop();
    incrementTaala();
    watch.start();
    getCurrentController().start();
  }

  incrementTaala() {
    taala.playingIndex = (taala.playingIndex + 1) % taala.playSeqence.length;
    if (taala.playingIndex == 0)
      setState(() {
        taala.count++;
      });
  }

  @override
  void initState() {
    super.initState();

    taala = TaalaData();
    sliderData = SliderData(min: 0.02, max: 4, value: 1);
    taalaSelectionData = TaalaSelectionData();
    jaathiSelectionData = JaathiSelectionData();
    watch = Stopwatch();
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

        animations = {
          TaalaStep.tap: TaalaAnimation('Tap'),
          TaalaStep.flip: TaalaAnimation('Flip'),
          TaalaStep.count1: TaalaAnimation('Count1'),
          TaalaStep.count2: TaalaAnimation('Count2'),
          TaalaStep.count3: TaalaAnimation('Count3'),
          TaalaStep.count4: TaalaAnimation('Count4'),
          TaalaStep.count5: TaalaAnimation('Count5')
        };

        animations.forEach((key, value) => artboard.addController(value));
        setState(() {
          riveArtboard = artboard;
          initializeTaalaState();
        });
      },
    );
  }

  TaalaAnimation getCurrentController() {
    var cur = animations[taala.playSeqence[taala.playingIndex]];
    return cur;
  }

  @override
  Widget build(BuildContext context) {
    if (riveArtboard == null) return Center(child: CircularProgressIndicator());
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Center(
              child: Rive(artboard: riveArtboard),
            ),
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(
                height: 36,
              ),
              Row(children: [
                SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  onPressed: sliderData.disableDecrease()
                      ? null
                      : () => sliderChanged(sliderData.value - 0.02),
                  child: Text("-.೦೨"),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                        thumbShape: const CustomSliderThumb1(),
                        showValueIndicator: ShowValueIndicator.never),
                    child: Slider(
                      value: sliderData.value,
                      min: sliderData.min,
                      max: sliderData.max,
                      onChanged: sliderChanged,
                      autofocus: false,
                      label: translateNumber(sliderData.value),
                      divisions: 200,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  onPressed: sliderData.disableIncrease()
                      ? null
                      : () => sliderChanged(sliderData.value + 0.02),
                  child: Text("+.೦೨"),
                ),
                SizedBox(
                  width: 8,
                ),
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    translateNumber(taala.count),
                    style: TextStyle(
                        fontFamily: 'Malige',
                        fontSize: 48,
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ]),

            //jaathi name display layer
            Positioned(
              bottom: 60,
              left: 0,
              height: 60,
              width: 300,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: () {
                          if (isPlaying) togglePlaying();
                          jaathiSelectionData.newSelection = taala.jaathi;
                          setState(
                              () => jaathiSelectionData.isSelecting = true);
                        },
                        child: Text(
                          kannadaTaalaJaathis[taala.jaathi],
                          style: TextStyle(
                              fontFamily: 'Malige',
                              fontSize: 36,
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.w700),
                        )),
                    Text(
                      ' ಜಾತಿ ',
                      style: TextStyle(
                          fontFamily: 'Malige',
                          fontSize: 32,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            //taala name display layer
            Positioned(
              bottom: 0,
              left: 130,
              height: 60,
              width: 200,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: () {
                          if (isPlaying) togglePlaying();
                          taalaSelectionData.newSelection = taala.taala;
                          setState(() => taalaSelectionData.isSelecting = true);
                        },
                        child: Text(
                          kannadaTaalaNames[taala.taala],
                          style: TextStyle(
                              fontFamily: 'Malige',
                              fontSize: 36,
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.w700),
                        )),
                    Text(
                      ' ತಾಳ',
                      style: TextStyle(
                          fontFamily: 'Malige',
                          fontSize: 32,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            // floating buttons layer
            Positioned(
                right: 20,
                bottom: 20,
                child: Column(children: [
                  //button for
                  FloatingActionButton(
                    onPressed: () {
                      taala.playingIndex = 0;
                      setState(() => taala.count = 0);
                      watch.reset();
                      initializeTaalaState();
                    },
                    tooltip: 'Restart',
                    child: Icon(Icons.refresh),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FloatingActionButton(
                    onPressed: togglePlaying,
                    tooltip: isPlaying ? 'Pause' : 'Play',
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                ])),
            //taala selection layer
            Visibility(
              visible: taalaSelectionData.isSelecting,
              child: Stack(children: [
                GestureDetector(
                  onTap: () {
                    if (taalaSelectionData.newSelection != taala.taala) {
                      taala.taala = taalaSelectionData.newSelection;
                      taala.buildSequence();
                      initializeTaalaState();
                      taala.count = 0;
                    }
                    setState(() => taalaSelectionData.isSelecting = false);
                  },
                  child: Container(
                    color: Colors.black26,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  bottom: -20,
                  left: 120,
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: ListWheelScrollView.useDelegate(
                        useMagnifier: true,
                        itemExtent: 36,
                        diameterRatio: 2,
                        magnification: 1.2,
                        squeeze: 1.2,
                        onSelectedItemChanged: (index) =>
                            taalaSelectionData.newSelection = index == 0
                                ? taala.taala
                                : TaalaType.values[index <=
                                        TaalaType.values.indexOf(taala.taala)
                                    ? index - 1
                                    : index],
                        childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) => Container(
                                    child: Container(
                                  color: Colors.blue.shade100,
                                  width: 90,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    kannadaTaalaNames[index == 0
                                        ? taala.taala
                                        : TaalaType.values[index <=
                                                TaalaType.values
                                                    .indexOf(taala.taala)
                                            ? index - 1
                                            : index]],
                                    style: TextStyle(
                                        fontFamily: 'Malige', fontSize: 24),
                                  ),
                                )),
                            childCount: TaalaType.values.length)),
                  ),
                ),
              ]),
            ),
            //jaathi selection layer
            Visibility(
              visible: jaathiSelectionData.isSelecting,
              child: Stack(children: [
                GestureDetector(
                  onTap: () {
                    if (jaathiSelectionData.newSelection != taala.jaathi) {
                      taala.jaathi = jaathiSelectionData.newSelection;
                      taala.buildSequence();
                      initializeTaalaState();
                      taala.count = 0;
                    }
                    setState(() => jaathiSelectionData.isSelecting = false);
                  },
                  child: Container(
                    color: Colors.black26,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 10,
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: ListWheelScrollView.useDelegate(
                        useMagnifier: true,
                        itemExtent: 36,
                        diameterRatio: 1.1,
                        magnification: 1.2,
                        squeeze: 1.4,
                        onSelectedItemChanged: (index) =>
                            jaathiSelectionData.newSelection = index == 0
                                ? taala.jaathi
                                : TaalaJaathi.values[index <=
                                        TaalaJaathi.values.indexOf(taala.jaathi)
                                    ? index - 1
                                    : index],
                        childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) => Container(
                                    child: Container(
                                  width: 120,
                                  height: 80,
                                  alignment: Alignment.center,
                                  color: Colors.green.shade200,
                                  child: Text(
                                    kannadaTaalaJaathis[index == 0
                                        ? taala.jaathi
                                        : TaalaJaathi.values[index <=
                                                TaalaJaathi.values
                                                    .indexOf(taala.jaathi)
                                            ? index - 1
                                            : index]],
                                    style: TextStyle(
                                        fontFamily: 'Malige', fontSize: 24),
                                  ),
                                )),
                            childCount: TaalaJaathi.values.length)),
                  ),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }
}
