import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // ─── AUTH ───────────────────────────────────────────

  static User? get currentUser => client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    if (response.user != null) {
      await createProfile(
        userId: response.user!.id,
        name: name,
        email: email,
      );
    }
    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ─── PROFILE ────────────────────────────────────────

  static Future<void> createProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    await client.from('profiles').upsert({
      'id': userId,
      'name': name,
      'email': email,
      'level': 1,
      'xp': 0,
      'streak': 0,
    });
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    if (currentUser == null) return null;
    final response = await client
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .single();
    return response;
  }

  static Future<void> updateProfile(Map<String, dynamic> data) async {
    if (currentUser == null) return;
    await client
        .from('profiles')
        .update(data)
        .eq('id', currentUser!.id);
  }

  static Future<void> addXP(int xp) async {
    final profile = await getProfile();
    if (profile == null) return;
    final currentXP = profile['xp'] as int;
    final currentLevel = profile['level'] as int;
    final newXP = currentXP + xp;
    int newLevel = currentLevel;
    if (newXP >= currentLevel * 500) {
      newLevel = currentLevel + 1;
    }
    await updateProfile({'xp': newXP, 'level': newLevel});
  }

  // ─── TASKS ──────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getTasks() async {
    if (currentUser == null) return [];
    final response = await client
        .from('tasks')
        .select()
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addTask({
    required String title,
    required String subject,
    required String time,
  }) async {
    if (currentUser == null) return;
    await client.from('tasks').insert({
      'user_id': currentUser!.id,
      'title': title,
      'subject': subject,
      'time': time,
      'is_done': false,
    });
  }

  static Future<void> toggleTask(String taskId, bool isDone) async {
    await client
        .from('tasks')
        .update({'is_done': isDone})
        .eq('id', taskId);
    if (isDone) await addXP(10);
  }

  static Future<void> deleteTask(String taskId) async {
    await client.from('tasks').delete().eq('id', taskId);
  }

  // ─── STUDY SESSIONS ─────────────────────────────────

  static Future<void> addStudySession({
    required String subject,
    required int durationMinutes,
  }) async {
    if (currentUser == null) return;
    await client.from('study_sessions').insert({
      'user_id': currentUser!.id,
      'subject': subject,
      'duration_minutes': durationMinutes,
      'date': DateTime.now().toIso8601String().split('T')[0],
    });
    await addXP(durationMinutes ~/ 5);
  }

  static Future<List<Map<String, dynamic>>> getStudySessions() async {
    if (currentUser == null) return [];
    final response = await client
        .from('study_sessions')
        .select()
        .eq('user_id', currentUser!.id)
        .order('date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, double>> getWeeklyStudyHours() async {
    if (currentUser == null) return {};
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final response = await client
        .from('study_sessions')
        .select()
        .eq('user_id', currentUser!.id)
        .gte('date', weekAgo.toIso8601String().split('T')[0]);

    final Map<String, double> weekData = {
      'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0,
      'Fri': 0, 'Sat': 0, 'Sun': 0,
    };

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (final session in response) {
      final date = DateTime.parse(session['date']);
      final dayName = days[date.weekday - 1];
      weekData[dayName] = (weekData[dayName] ?? 0) +
          (session['duration_minutes'] as int) / 60.0;
    }
    return weekData;
  }

  static Future<Map<String, double>> getSubjectBreakdown() async {
    if (currentUser == null) return {};
    final sessions = await getStudySessions();
    final Map<String, double> breakdown = {};
    for (final session in sessions) {
      final subject = session['subject'] as String;
      breakdown[subject] = (breakdown[subject] ?? 0) +
          (session['duration_minutes'] as int) / 60.0;
    }
    return breakdown;
  }
}
