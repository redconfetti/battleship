'use strict';
var battleship = angular.module('battleship', [
  'templates',
  'ngRoute',
  'Devise'
]);

/**
 * Battleship main controller
 */
angular.module('battleship').controller('BattleshipController', ['$rootScope', 'Auth', function($rootScope, Auth) {

  /**
   * Will be executed on every route change
   *  - Get the player information when it hasn't been loaded yet
   */
  $rootScope.$on('$routeChangeSuccess', function(evt, current) {
    // alert('route changed');
  });

  // load current user
  Auth.currentUser();

  $rootScope.$on('devise:login', function(event, currentUser) {
    $rootScope.isAuthenticated = Auth.isAuthenticated();

    // redirect to homepage when on signup or login page
    if ( ['#/sign-up', '#/login'].indexOf($window.location.hash) !== -1 ) {
      $window.location.href = '/';
    }
  });
}]);
