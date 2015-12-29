angular.module('battleship').controller('LoginController', ['$rootScope', '$scope', '$routeParams', '$window', 'Auth', function LoginController($rootScope, $scope, $routeParams, $window, Auth) {

  $scope.createSession = function() {
    var credentials = {
      email: $scope.email,
      password: $scope.password
    };

    var config = {
      headers: {
        'X-HTTP-Method-Override': 'POST'
      }
    };

    Auth.login(credentials, config).then(function(player) {
      console.log(player);
    }, function(error) {
      console.log(error);
    });

  };

  $scope.destroySession = function() {
    var config = {
      headers: {
        'X-HTTP-Method-Override': 'DELETE'
      }
    };

    Auth.logout(config).then(function(oldUser) {
      // console.log(oldUser);
      $rootScope.isAuthenticated = Auth.isAuthenticated();
    }, function(error) {
      console.log('logged out user error');
      console.log(error);
    });
  };

  $scope.$on('devise:login', function(event, currentUser) {
    $rootScope.isAuthenticated = Auth.isAuthenticated();

    // redirect to homepage when on signup or login page
    if ( ['#/sign-up', '#/login'].indexOf($window.location.hash) !== -1 ) {
      $window.location.href = '/';
    }
  });

  $scope.$on('devise:new-session', function(event, currentUser) {
    // console.log('new session established');
  });

}]);
