// We use an enum to strictly define what roles are allowed in the app.
// This prevents typos like saving "boothworker" vs "booth_worker" in the database.
enum WorkerRole { districtAdmin, wardPresident, boothWorker }

class WorkerModel {
  final String uid; // Their secure Firebase Authentication ID
  final String name; // e.g., "Amit Patel"
  final String phoneNumber; // Used for login
  final WorkerRole role; // Admin, Ward President, or Booth Worker

  // These are optional (nullable) because a District Admin isn't tied to one specific booth.
  final int? assignedWard;
  final int? assignedBooth;

  WorkerModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.assignedWard,
    this.assignedBooth,
  });

  // 1. Convert Firestore JSON data into our Flutter Object
  factory WorkerModel.fromMap(Map<String, dynamic> map, String documentId) {
    return WorkerModel(
      uid: documentId,
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      // Convert the string from the database back into our Enum
      role: WorkerRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => WorkerRole.boothWorker, // Default fallback for safety
      ),
      assignedWard: map['assignedWard'],
      assignedBooth: map['assignedBooth'],
    );
  }

  // 2. Convert our Flutter Object back into JSON to save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role
          .toString()
          .split('.')
          .last, // Saves as "districtAdmin", "boothWorker", etc.
      'assignedWard': assignedWard,
      'assignedBooth': assignedBooth,
    };
  }
}
