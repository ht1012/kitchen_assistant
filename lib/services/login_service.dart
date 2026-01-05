import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Household.dart';
class LoginService {
  CollectionReference get householdsCollection =>
  FirebaseFirestore.instance.collection('households');

  Future<Household?> getHouseholdByCode(String code) async {
    QuerySnapshot snapshot =
        await householdsCollection.where('household_code', isEqualTo: code).get();

    if (snapshot.docs.isNotEmpty) {
      var doc = snapshot.docs.first;
      return Household.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> createHousehold(String householdName, String householdCode) async {
    await householdsCollection.add({
      'household_name': householdName,
      'household_code': householdCode,
    });
  }
}