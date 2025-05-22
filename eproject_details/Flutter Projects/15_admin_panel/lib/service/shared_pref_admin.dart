import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  Future<void> saveAdminData(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('adminName', name);

    print("Admin data saved: $name");
  }

  Future<String?> getAdminData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('adminName');

    print("Admin data fetched: $name");
    return name;
  }

  Future<void> clearAdminData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminData');
  }
}
