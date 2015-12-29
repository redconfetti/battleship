angular.module('battleship').config(['$routeProvider', function($routeProvider) {
  $routeProvider
    .when('/', {
      templateUrl: 'index.html',
      controller: 'HomeController',
    })
    .when('/sign-up', {
      templateUrl: 'register.html',
      controller: 'RegistrationController'
    })
    .when('/login', {
      templateUrl: 'login.html',
      controller: 'LoginController',
    })
    .otherwise({ redirectTo: '/' });
}]);
