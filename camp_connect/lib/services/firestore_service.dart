import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  Future<void> addUserData(String uid, Map<String, dynamic> data) async {
    await users.doc(uid).set(data);
  }

  Stream<QuerySnapshot> getUsers() {
    return users.snapshots();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await users.doc(uid).update(data);
  }

  Future<void> deleteUser(String uid) async {
    await users.doc(uid).delete();
  }
}
