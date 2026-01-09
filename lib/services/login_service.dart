import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Household.dart';
class LoginService {
  CollectionReference get householdsCollection =>
  FirebaseFirestore.instance.collection('households');

  Future<Household?> getHouseholdByCode(String code) async {
    try {
      QuerySnapshot snapshot =
          await householdsCollection.where('household_code', isEqualTo: code).get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        return Household.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Không thể tìm kiếm hộ gia đình: ${e.toString()}');
    }
  }

  Future<void> createHousehold(String householdName, String householdCode) async {
    try {
      await householdsCollection.add({
        'household_name': householdName,
        'household_code': householdCode,
      });
    } catch (e) {
      throw Exception('Không thể tạo hộ gia đình: ${e.toString()}');
    }
  }
}