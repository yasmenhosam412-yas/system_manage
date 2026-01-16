class ErrorHelper {
  static String format(String error) {
    final e = error.toLowerCase();
    if (e.contains("email-already-in-use")) {
      return "The email address is already in use by another account.";
    } else if (e.contains("invalid-email")) {
      return "The email address is not valid.";
    } else if (e.contains("operation-not-allowed")) {
      return "Email/password accounts are not enabled.";
    } else if (e.contains("weak-password")) {
      return "The password is too weak. Please choose a stronger password.";
    } else if (e.contains("user-not-found")) {
      return "No user found with this email.";
    } else if (e.contains("wrong-password")) {
      return "Incorrect password. Please try again.";
    } else if (e.contains("credential is incorrect")) {
      return "Incorrect email or password. Please try again.";
    } else if (e.contains("blocked")) {
      return "We have blocked all requests from this device due to unusual activity. Try again later.";
    }

    return "Something went wrong. Please try again.";
  }
}
