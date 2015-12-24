angular.module('battleship').controller('RegistrationController', ['$scope', '$routeParams', 'Auth', function RegistrationController($scope, $routeParams, Auth) {

  $scope.submitRegistration = function() {

    var credentials = {
      email: $scope.email,
      password: $scope.password,
      password_confirmation: $scope.password_confirmation
    };
    console.log(credentials);

    var config = {
      headers: {
        'X-HTTP-Method-Override': 'POST'
      }
    };

    Auth.register(credentials, config).then(function(registeredPlayer) {
      console.log('success');
      console.log(registeredPlayer);
    }, function(error) {
      console.log('failure');
      console.log(error);
    });

    $scope.$on('devise:new-registration', function(event, player) {
      console.log('new player');
      console.log(player);
    });

  };

}]);
