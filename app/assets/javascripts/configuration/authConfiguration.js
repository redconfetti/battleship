angular.module('battleship').config(['AuthProvider', function(AuthProvider) {
  // Customize the resource name data use namespaced under
  AuthProvider.resourceName('player');

  // Customize register
  AuthProvider.registerMethod('POST');
  AuthProvider.registerPath('/players.json');
}]);
