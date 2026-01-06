class Household {
  final String id;
  final String householdCode;
  final String householdName;

  Household({required this.id, required this.householdCode, required this.householdName});

  factory Household.fromJson(Map<String, dynamic> json, String id) {
    return Household(
      id: id,
      householdCode: json['household_code'],
      householdName: json['household_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'household_code': householdCode,
      'household_name': householdName,
    };
  }
}