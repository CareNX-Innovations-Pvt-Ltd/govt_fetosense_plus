/*
This class defines all the possible read/write locations from the FirebaseFirestore database.
In future, any new path can be added here.
This class work together with FirestoreService and FirestoreDatabase.
 */

class FirestorePath {
  static String mainCollection = "organizations";
  static String organization(String oid) => '$mainCollection/$oid';
  static String adminCollection(String oid) => 'organizations_admin/$oid';

  static String adminUser(String oid, String uid) =>
      '${adminCollection(oid)}/org_users/$uid';
  static String user(String oid, String uid) =>
      '$mainCollection/$oid/org_users/$uid';
  static String users(String oid) => '$mainCollection/$oid/org_users';

  static String test(String oid, String testId) =>
      '$mainCollection/$oid/user_tests/$testId';
  static String tests(String oid) => '$mainCollection/$oid/user_tests';
}
