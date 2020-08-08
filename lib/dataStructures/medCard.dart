import '../utils/utils.dart';

enum CardType { medication, drip }

class Medcard {
  String name;
  String notes;
  CardType type; //medication or driptable

  String concStr; //constant to divide from dosage (mg/ml or mcg/ml)
  double concVal;
  String concUnit; //same unit as first unit in concStr
  String concFormulaStr; //same unit as first unit in concStr
  int currDose = 0; //index of current dosage corresponding to dosages list
  bool administered = false; // true if has been administered before

  List<double>
      firstDosages; //list of dosages for buttons for first dose (mg/kg or mcg/kg)
  List<double>
      seqDosages; //list of dosages for buttons for subsequent dose (mg/kg or mcg/kg)

  double firstMin;
  double firstMax;
  double seqMin;
  double seqMax;

  Medcard(
      this.name,
      this.notes,
      this.type,
      this.concStr,
      this.firstDosages,
      this.seqDosages,
      this.firstMin,
      this.firstMax,
      this.seqMin,
      this.seqMax,
      this.concFormulaStr) {
    double numerator;
    double denominator;

    var originalString = concFormulaStr;
    var string = originalString.split("/");

    String numerStr = string[0];
    String denomStr = string[1];
    for (int i = 0; i < numerStr.length; ++i) {
      if (!isDigit(numerStr[i]) & (numerStr[i] != ".")) {
        this.concUnit = this.type == CardType.medication
            ? numerStr.substring(i)
            : numerStr.substring(i);
        numerator = double.parse(numerStr.substring(0, i));
        break;
      }
    }
    for (int i = 0; i < denomStr.length; ++i) {
      if (!isDigit(denomStr[i]) & (numerStr[i] != ".")) {
        if (i == 0) {
          denominator = 1;
        } else {
          denominator = double.parse(denomStr.substring(0, i));
        }
        break;
      }
    }

    this.concVal = numerator / denominator;
  }
}