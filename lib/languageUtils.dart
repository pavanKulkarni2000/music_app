import 'package:music_app/taala.dart';

Map kannadaNumbers = {
  '0': '೦',
  '1': '೧',
  '2': '೨',
  '3': '೩',
  '4': '೪',
  '5': '೫',
  '6': '೬',
  '7': '೭',
  '8': '೮',
  '9': '೯'
};

Map kannadaTaalaNames = {
  TaalaType.dhruva:'ಧ್ರುವ',
  TaalaType.mathya:'ಮಠ್ಯ',
  TaalaType.rupaka:'ರೂಪಕ',
  TaalaType.jhumpa:'ಝಂಪೆ',
  TaalaType.triputa:'ತ್ರಿಪುಟ',
  TaalaType. atta:'ಅಟ್ಟ',
  TaalaType.eka:'ಏಕ',
};

Map kannadaTaalaJaathis = {
  TaalaJaathi.thrishra:' ತ್ರಿಶ್ರ',
  TaalaJaathi.chaturashra:'ಚತುರಶ್ರ',
  TaalaJaathi.khanda:'ಖಂಡ',
  TaalaJaathi.mishra:'ಮಿಶ್ರ',
  TaalaJaathi.sankeerna:'ಸಂಕೀರ್ಣ',
};

String translateNumber(value) {
  String translatedStr = "";
  String str = value.toString();
  for (int i = 0; i < str.length; i++) {
    if (kannadaNumbers.containsKey(str[i]))
      translatedStr += kannadaNumbers[str[i]];
    else
      translatedStr += str[i];
  }
  return translatedStr;
}
