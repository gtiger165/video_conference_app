import 'package:firebase_database/firebase_database.dart';
import 'package:video_conference_app/data/model/video_conference_model.dart';

class VCDao {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref("video");

  Future pushOrder(VideoConferenceModel data) => _ref.set(data.toJson());

  Query getQuery() => _ref;

  Future readOrder() => _ref.once();

  Future updateOrder(bool status) => _ref.update({"status": status});
}
