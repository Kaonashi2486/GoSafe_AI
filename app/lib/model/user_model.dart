class UserDataService {
  String username = "";
  String password = "";

  // Example method to set user data
  Future<void> setUserData(String newUsername, String newPassword) async {
    username = newUsername;
    password = newPassword;
    return;
  }

  // Example method to get user data
  String getUserData() {
    return "Username: $username, Password: $password";
  }

  Future<void> logout() async {
    username = '';
    password = '';
    return;
  }

  // Helper method to check if the user is logged in
  Future<bool> isLoggedIn() async {
    // If both username and password are set (non-empty), consider the user as logged in
    return username.isNotEmpty && password.isNotEmpty;
  }
}

//how to use
//  @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
