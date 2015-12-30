angular.module('battleship').controller('RegistrationController', ['$scope', 'Auth', function RegistrationController($scope, Auth) {

  $scope.submitRegistration = function() {
    var credentials = {
      email: $scope.email,
      password: $scope.password
    };

    var config = {
      headers: {
        'X-HTTP-Method-Override': 'POST'
      }
    };

    Auth.register(credentials, config).then(function(registeredPlayer) {
      $scope.registrationSuccess = true;
      $scope.registrationErrors = null;
    }, function(error) {
      $scope.registrationSuccess = false;
      $scope.registrationErrors = error.data.errors;
    });

    $scope.$on('devise:new-registration', function(event, player) {
      $scope.registrationSuccess = true;
    });
  };

}]);
