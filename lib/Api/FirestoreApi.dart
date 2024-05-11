import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreApi {

  static Future<List<String>> listAllDocuments(String collectionPath1, String email, String collectionPath2) async{
    final collectionReference = FirebaseFirestore.instance.collection(collectionPath1).doc(email).collection(collectionPath2);
    final querySnapshot = await collectionReference.get();

    return querySnapshot.docs.map((doc) => doc.id).toList();
  }

  static Future<Map<String, dynamic>> getDocumentData(String collectionPath1, String email, String collectionPath2, String documentId) async {
    final documentReference = FirebaseFirestore.instance.collection(collectionPath1).doc(email).collection(collectionPath2).doc(documentId);
    final documentSnapshot = await documentReference.get();

    return documentSnapshot.data() ?? {};
  }
}
