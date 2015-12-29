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
}]);
