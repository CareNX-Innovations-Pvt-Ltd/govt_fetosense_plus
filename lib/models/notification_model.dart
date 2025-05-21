class Notification {
  String? documentId;

  String? module;
  String? type;
  String? title;
  String? message;
  bool read = false;
  bool delete = false;
  String? imageUrl;
  String? link;
  DateTime? createdOn;
  String? createdBy;

  Notification() {}

  Notification.fromMap(Map snapshot, String id)
      : documentId = snapshot['documentId'] ?? '',
        module = snapshot['module'] ?? '',
        type = snapshot['type'] ?? '',
        title = snapshot['title'] ?? '',
        message = snapshot['body'] ?? '',
        read = snapshot['isRead'] ?? false,
        delete = snapshot['delete'] ?? false,
        imageUrl = snapshot['imageUrl'] ?? '',
        link = snapshot['link'] ?? '',
        createdOn = snapshot['createdAt'].toDate(),
        createdBy = snapshot['createdBy'] ?? '';
}
