class MarkerIndices {
  MarkerIndices();
  MarkerIndices.fromData(int this.from, int this.to);
  MarkerIndices.from({required int this.from, required int this.to});

  int? from;
  int? to;

  void setFrom(int from) {
    this.from = from;
  }

  int? getFrom() {
    return from;
  }

  int? getTo() {
    return to;
  }

  void setTo(int to) {
    this.to = to;
  }

  Map<String, int>toMap(){
    Map<String,int> m = {};
    m["from"] = from??0;
    m["to"] = to??0;
    return m;
  }

}
