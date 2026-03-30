import 'package:shared_preferences/shared_preferences.dart';

class BrainDumpLimitService {
  static const int freeLimit = 3;

  static Future<int> getTodayUsage() async {
    final prefs = await SharedPreferences.getInstance();

    final today =
        DateTime.now().toIso8601String().substring(0, 10);

    final storedDate =
        prefs.getString("brain_dump_date");

    if (storedDate != today) {
      await prefs.setString(
          "brain_dump_date", today);

      await prefs.setInt(
          "brain_dump_count", 0);

      return 0;
    }

    return prefs.getInt(
            "brain_dump_count") ??
        0;
  }

  static Future<bool> canUse() async {
    final count =
        await getTodayUsage();

    return count < freeLimit;
  }

  static Future<void> increment() async {
    final prefs =
        await SharedPreferences.getInstance();

    int count =
        prefs.getInt(
                "brain_dump_count") ??
            0;

    await prefs.setInt(
        "brain_dump_count",
        count + 1);
  }
}