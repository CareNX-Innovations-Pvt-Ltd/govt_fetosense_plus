class FhrCommandMaker {
  static List<int> monitor(final int value) {
    final List<int> cmd = List.generate(5, (index) => 0);
    int tmp = value;
    if (value > 3 || value < 0) {
      tmp = 0;
    }
    cmd[0] = 85;
    cmd[1] = 170;
    cmd[2] = 10;
    cmd[3] = value;
    cmd[4] = 0;
    return cmd;
  }
  static List<int> tocoReset(final int value) {
    final List<int> cmd = List.generate(10, (index) => 0);
    int tmp = value;

    cmd[0] = 85;
    cmd[1] = 170;
    cmd[2] = 02;
    cmd[3] = 21;
    cmd[4] = 224;
    cmd[5] = 85;
    cmd[6] = 170;
    cmd[7] = 03;
    cmd[8] = 0;
    cmd[9] = value;
    return cmd;
  }
  //[85,170,02,16,0,85,170,02,18,07]
  static List<int> fhrVolume(final int value,final int path) {
    final List<int> cmd = List.generate(10, (index) => 0);
    int tmp = value;
    if (value > 7 || value < 0) {
      tmp = 0;
    }
    cmd[0] = 85;
    cmd[1] = 170;
    cmd[2] = 02;
    cmd[3] = 16 + path;
    cmd[4] = 0;
    cmd[5] = 85;
    cmd[6] = 170;
    cmd[7] = 02;
    cmd[8] = 18;
    cmd[9] = value;
    return cmd;
  }

  static List<int> buildCommandPacket() {
    final List<int> packet = [];

    // 1. Header identifier
    packet.addAll([0x55, 0xAA]);

    // 2. Total packet length (5 bytes = Reserved + Control + Checksum), little-endian
    packet.addAll([0x05, 0x00]);

    // 3. Reserved word
    packet.add(0);

    // 4. Control word ID
    packet.add(0xA6);


    // 5. No data
    packet.add(0);

    // 6. Checksum = sum of all bytes except checksum byte
    int checksum = packet.fold(0, (sum, b) => (sum + b) & 0xFF);
    packet.add(checksum);

    return packet;
  }
  static List<int> testMode() {
    final List<int> cmd = List.generate(10, (index) => 0);
    cmd[0] = 85;
    cmd[1] = 170;
    cmd[2] = 02;
    cmd[3] = 0Xa6;
    cmd[4] = 0;
    return cmd;
  }

  static List<int> alarmVolume(final int value) {
    final List<int> cmd = List.generate(9, (index) => 0);
    int tmp = value;
    if (value > 7 || value < 0) {
      tmp = 0;
    }
    cmd[0] = 85;
    cmd[1] = -86;
    cmd[2] = 10;
    cmd[3] = -1;
    cmd[5] = (cmd[4] = -1);
    cmd[6] = tmp;
    cmd[7] = -1;
    cmd[8] = makeSum(cmd);
    return cmd;
  }

  static List<int> path(final int value) {
    final List<int> cmd = List.generate(8, (index) => 0);
    int tmp = value;
    if (value > 7 || value < 0) {
      tmp = 0;
    }
    cmd[0] = 85;
    cmd[1] = -86;
    cmd[2] = 10;
    cmd[3] = -1;
    cmd[4] = -1;
    cmd[5] = 1;
    cmd[6] = tmp;
    cmd[7] = makeSum(cmd);
    return cmd;
  }

  static List<int> alarmLevel(final int value) {
    final List<int> cmd = List.generate(9, (index) => 0);
    int tmp = value;
    if (value > 0 || value < 0) {
      tmp = 0;
    }
    cmd[0] = 85;
    cmd[1] = -86;
    cmd[2] = 10;
    cmd[4] = (cmd[3] = -1);
    cmd[6] = (cmd[5] = -1);
    cmd[7] = tmp;
    cmd[8] = makeSum(cmd);
    return cmd;
  }

  static int makeSum(final List<int> cmd) {
    final int len = cmd.length - 4;
    int sum = 0;
    for (int i = 0; i < len; ++i) {
      sum = (sum + cmd[3 + i] & 0xFF);
    }
    return sum;
  }
}
