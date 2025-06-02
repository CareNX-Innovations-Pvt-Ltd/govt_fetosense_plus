import 'package:l8fe/utils/fhr_data.dart';

abstract class BaseBluetoothService {
  Future<void> connect(dynamic device);
  Future<void> disconnect();
  Stream<FhrData?> get dataStream;
}
