import 'dart:math';
import 'package:rive/rive.dart';

enum TaalaJaathi { thrishra, chaturashra, khanda, mishra, sankeerna }

enum TaalaType { dhruva, mathya, rupaka, jhumpa, triputa, atta, eka }

enum Anga { laghu, dhruta, anudhruta }

enum TaalaStep { tap, flip, count1, count2, count3, count4, count5 }

Map _taalaCompositions = {
  TaalaType.dhruva: [Anga.laghu, Anga.dhruta, Anga.laghu, Anga.laghu],
  TaalaType.mathya: [Anga.laghu, Anga.dhruta, Anga.laghu],
  TaalaType.rupaka: [Anga.dhruta, Anga.laghu],
  TaalaType.triputa: [Anga.laghu, Anga.dhruta, Anga.dhruta],
  TaalaJaathi.khanda: [Anga.laghu, Anga.laghu, Anga.dhruta, Anga.dhruta],
  TaalaType.jhumpa: [Anga.laghu, Anga.anudhruta, Anga.dhruta],
  TaalaType.eka: [Anga.laghu],
};

class TaalaAnimation extends SimpleAnimation {
  TaalaAnimation(String animationName) : super(animationName);

  setState(TaalaData data) {
    isActive = false;
    reset();
    instance.animation.fps = min(60 ~/ data.speed, 60);
    instance.animation.speed = data.speed;
    instance.animation.loop = Loop.loop;
  }

  get timeElapsed => instance.progress;

  setSpeed(double speed) {
    instance.animation.speed = speed;
  }

  stop() {
    reset();
    isActive = false;
  }

  start() {
    isActive = true;
  }
}

class TaalaData {
  int playingIndex;
  double speed;
  int fps;
  TaalaType taala;
  TaalaJaathi jaathi;
  List<TaalaStep> playSeqence;
  String name = "ಆದಿತಾಳ";
  TaalaData(
      {this.speed = 1,
      this.fps = 60,
      this.taala = TaalaType.triputa,
      this.jaathi = TaalaJaathi.chaturashra}) {
    playSeqence = [];
    buildSequence();
  }

  bool operator ==(covariant TaalaData data) {
    return data.speed == speed && data.fps == fps;
  }

  @override
  int get hashCode => super.hashCode;

  buildSequence() {
    playSeqence.clear();
    for (var x in _taalaCompositions[taala]) {
      switch (x) {
        case Anga.anudhruta:
          playSeqence.add(TaalaStep.tap);
          break;
        case Anga.dhruta:
          playSeqence.add(TaalaStep.tap);
          playSeqence.add(TaalaStep.flip);
          break;
        case Anga.laghu:
          switch (jaathi) {
            case TaalaJaathi.thrishra:
              playSeqence.add(TaalaStep.tap);
              playSeqence.add(TaalaStep.count1);
              playSeqence.add(TaalaStep.count2);
              break;
            case TaalaJaathi.chaturashra:
              playSeqence.add(TaalaStep.tap);
              playSeqence.add(TaalaStep.count1);
              playSeqence.add(TaalaStep.count2);
              playSeqence.add(TaalaStep.count3);
              break;
            case TaalaJaathi.khanda:
              playSeqence.add(TaalaStep.tap);
              playSeqence.add(TaalaStep.count1);
              playSeqence.add(TaalaStep.count2);
              playSeqence.add(TaalaStep.count3);
              playSeqence.add(TaalaStep.count4);
              break;
            case TaalaJaathi.mishra:
              playSeqence.add(TaalaStep.tap);
              playSeqence.add(TaalaStep.count1);
              playSeqence.add(TaalaStep.count2);
              playSeqence.add(TaalaStep.count3);
              playSeqence.add(TaalaStep.count4);
              playSeqence.add(TaalaStep.count5);
              playSeqence.add(TaalaStep.count1);
              break;
            case TaalaJaathi.sankeerna:
              playSeqence.add(TaalaStep.tap);
              playSeqence.add(TaalaStep.count1);
              playSeqence.add(TaalaStep.count2);
              playSeqence.add(TaalaStep.count3);
              playSeqence.add(TaalaStep.count4);
              playSeqence.add(TaalaStep.count5);
              playSeqence.add(TaalaStep.count1);
              playSeqence.add(TaalaStep.count2);
              playSeqence.add(TaalaStep.count3);
              break;
          } //switch jathi
          break;
      } //switch taala composition
    } //loop through taala composition
    playingIndex = 0;
  }
}

class TaalaSelectionData {
  bool isSelecting=false;
  TaalaType newSelection=TaalaType.triputa;
}

class JaathiSelectionData {
  bool isSelecting=false;
  TaalaJaathi newSelection=TaalaJaathi.chaturashra;
}
