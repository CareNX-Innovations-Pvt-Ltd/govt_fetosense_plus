typedef OnTap = void Function()?;

typedef TxtFieldOnSaved = void Function(String?);

typedef TxtFieldOnChanged = void Function(String);

typedef TxtFieldOnSubmit = void Function(String);

typedef TxtFieldValidator = String? Function(String?);

//Convert single day, month, etc values to two digits
String dualDigitize(int? x) => x == null
    ? '0'
    : x < 10
        ? '0$x'
        : '$x';

//Return with one letter caps
String capitalize(String s) => s.replaceFirstMapped(
      RegExp(r'.'),
      (match) => '${match[0]}'.toUpperCase(),
    );

class Regex {
  Regex._();

  static final whitespace = RegExp(r' ');
  static final email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final phone =
      RegExp(r'[\+][(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$');
  static final password = RegExp(r'.{6}');
  static final otp = RegExp(r'[0-9]{6}');
}

String getTestType(String? type) {
  type = type?.toUpperCase();
  switch (type) {
    case "WEL":
      return "Wellness";
    case "UTI":
      return "UTI";
    case "CKD":
      return "CKD";
    case "PRG":
      return "Pregnancy care";
    case "ELD":
      return "Elderly care";
    case "IUT":
      return "Urine Test";
    default:
      return "Wellness";
  }
}

// extension ListUtils on List<int> {
//   List<int> operator /(int x) {
//     for (var e in this) {
//       e = e ~/ x;
//     }
//     return this;
//   }
// }

extension MapUtils on Map<String, dynamic> {
  void mergeNumberMap(Map<String, dynamic> other) {
    for (var entry in other.entries) {
      if (containsKey(entry.key)) {
        if (entry.value is num) {
          this[entry.key] += entry.value;
        } else {
          (this[entry.key] as Map<String, dynamic>)
              .mergeNumberMap(entry.value as Map<String, dynamic>);
        }
      } else {
        this[entry.key] = entry.value;
      }
    }
  }
}
