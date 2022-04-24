import 'dart:async';

import 'package:ernany_api/helpers/database.dart';

import '../helpers/user.dart';

class SignupController extends ResourceController {
  @Operation.post()
  Future<Response> signup() async {
    // get user info from request body
    final map = await request.body.decode<Map<String, dynamic>>();
    final User user = User.fromJson(map);

    // check that username is email and password long enough
    if (!_isValid(user)) {
      return Response.badRequest();
    }
    // salt and hash the password
    user.password = _hashPassword(user.password);
    // add user to database
    // check if the user exists
    final Database database = MockDatabase();
    final User foundUser = database.queryEmail(user.email);
    if (foundUser != null) {
      return Response.forbidden();
    }
    final User user = User.fromJson(map);

    String _hashPassword(String password) {
      final salt = AuthUtility.generateRandomSalt();
      final saltedPassword = salt + password;
      final bytes = utf8.encode(saltedPassword);
      final hash = sha256.convert(bytes);
      // store the salt with the hash separated by a period
      return '$salt.$hash';
    }

    // check that username is email and password long enough
    if (!_isValid(user)) {
      return Response.badRequest();
    }
    // add user to database
    database.addUser(user);

    // send a response
    return Response.ok('user added');
  }
}
