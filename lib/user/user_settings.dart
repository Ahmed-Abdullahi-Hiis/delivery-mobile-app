import 'package:flutter/material.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  bool notificationsEnabled = true;
  bool darkMode = false;
  bool autoUpdates = true; // example additional setting

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Settings",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // ---------------- Account & Preferences Section ----------------
          _sectionTitle("Preferences"),
          const SizedBox(height: 12),

          _settingCard(
            icon: Icons.notifications_active,
            title: "Enable Notifications",
            value: notificationsEnabled,
            onChanged: (val) => setState(() => notificationsEnabled = val),
            activeColor: Colors.blue,
          ),

          _settingCard(
            icon: Icons.dark_mode,
            title: "Dark Mode",
            value: darkMode,
            onChanged: (val) => setState(() => darkMode = val),
            activeColor: Colors.deepPurple,
          ),

          _settingCard(
            icon: Icons.update,
            title: "Auto Updates",
            value: autoUpdates,
            onChanged: (val) => setState(() => autoUpdates = val),
            activeColor: Colors.green,
          ),

          const SizedBox(height: 24),

          // ---------------- App Info / Actions Section ----------------
          _sectionTitle("Account & Support"),
          const SizedBox(height: 12),

          _actionCard(
            icon: Icons.lock,
            title: "Change Password",
            onTap: () {
              // Navigate to change password page
            },
          ),
          _actionCard(
            icon: Icons.help_outline,
            title: "Help & FAQ",
            onTap: () {
              // Navigate to FAQ/help page
            },
          ),
          _actionCard(
            icon: Icons.logout,
            title: "Logout",
            iconColor: Colors.redAccent,
            onTap: () {
              // Logout action
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _settingCard({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        secondary: Icon(icon, color: activeColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        value: value,
        activeColor: activeColor,
        onChanged: onChanged,
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    Color iconColor = Colors.blue,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
