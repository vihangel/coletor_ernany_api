import 'dart:async';
import 'dart:convert';
import 'package:aqueduct/aqueduct.dart';
import 'package:dart_auth/helpers/user.dart';
import 'package:dart_auth/helpers/database.dart';

class RestrictedController extends ResourceController {
  @Operation.get()
  Future<Response> restricted(
      @Bind.header("authorization") String authHeader) async {
    // only allow with correct username and password
    if (!_isAuthorized(authHeader)) {
      return Response.forbidden();
    }

    // We are returning a string here, but this could be
    // a file or data from the database.
    return Response.ok('restricted resource');
  }

  // parse the auth header
  bool _isAuthorized(String authHeader) {
    final parts = authHeader.split(' ');
    if (parts == null || parts.length != 2 || parts[0] != 'Basic') {
      return false;
    }
    return _isValidUsernameAndPassword(parts[1]);
  }

  // check username and password
  bool _isValidUsernameAndPassword(String credentials) {
    // this user
    final String decoded = utf8.decode(base64.decode(credentials));
    final parts = decoded.split(':');
    final User user = User(parts[0], parts[1]);

    // database user
    final Database database = MockDatabase();
    final User foundUser = database.queryEmail(user.email);

    // check for match
    return foundUser != null && foundUser.password == user.password;
  }
}
