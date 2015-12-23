angular.module('battleship', ['Devise'])
	config(['AuthProvider', function(AuthProvider) {
		// Customize the resource name data use namespaced under
    AuthProvider.resourceName('player');
  });
