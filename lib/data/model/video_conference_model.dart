class VideoConferenceModel {
  VideoConferenceModel({
    this.idOrder,
    this.room,
    this.serverUrl,
    this.status,
  });

  VideoConferenceModel.fromJson(dynamic json) {
    idOrder = json['id_order'];
    room = json['room'];
    serverUrl = json['server_url'];
    status = json['status'];
  }
  int? idOrder;
  String? room;
  String? serverUrl;
  bool? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id_order'] = idOrder;
    map['room'] = room;
    map['server_url'] = serverUrl;
    map['status'] = status;
    return map;
  }
}
