angular.module('battleship').config(['AuthProvider', function(AuthProvider) {
  // Customize the resource name data use namespaced under
  AuthProvider.resourceName('player');

  // Customize Register
  AuthProvider.registerMethod('POST');
  AuthProvider.registerPath('/players.json');

  // Customize Login
  AuthProvider.loginMethod('POST');
  AuthProvider.loginPath('/players/sign_in.json');

  // Customize Logout
  AuthProvider.logoutMethod('DELETE');
  AuthProvider.logoutPath('/players/sign_out.json');
}]);
