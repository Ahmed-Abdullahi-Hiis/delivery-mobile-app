 class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return "Email required";
    if (!value.contains("@")) return "Invalid email";
    return null;
  }
}
