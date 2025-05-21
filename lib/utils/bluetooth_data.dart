import 'dart:typed_data';

class DataType
{
  static const int TYPE_NONE = 0;
  static const int TYPE_SOUND = 1;
  static const int TYPE_FHR = 2;
  static const int TYPE_SOUND2 = 11;
}
class BluetoothData
{
  static const BUFFER_SIZE = 13;
  int dataType = DataType.TYPE_NONE;
  Uint8List mValue = Uint8List(BUFFER_SIZE);
  BluetoothData();
}
