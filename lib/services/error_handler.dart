class ErrorHandler {
  //NOT WORKING FOR NOW
  static String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case "ERROR_OPERATION_NOT_ALLOWED":
        return "Anonymous accounts are not enabled";
      case "ERROR_WEAK_PASSWORD":
        return "Your password is too weak";
      case "ERROR_INVALID_EMAIL":
        return "Your email is invalid";
      case "ERROR_EMAIL_ALREADY_IN_USE":
        return "Email is already in use on different account";
      case "INVALID_LOGIN_CREDENTIALS":
        return "Your email is invalid";
      case "wrong-password":
        return "Incorrect password.";
      case "invalid-email":
        return "Email address is invalid.";
      case "user-not-found":
        return "No user found with this email.";
      case "user-disabled":
        return "User disabled.";
      case "weak-password":
        return "Password is too weak.";
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return "Email already used. Go to login page.";
      case "ERROR_WRONG_PASSWORD":
        return "Wrong email/password combination.";
      case "ERROR_USER_NOT_FOUND":
        return "No user found with this email.";
      case "ERROR_USER_DISABLED":
        return "User disabled.";
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return "Too many requests to log into this account.";
      default:
        return "An undefined error happened. Please try again.";
    }
  }
}
