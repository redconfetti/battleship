angular.module('battleship').controller('GameController', ['$http', '$scope', function GameController($http, $scope) {

  $scope.getPendingGames = function() {
    $scope.pendingGames = [];

    $http({
      method: 'GET',
      url: '/games/pending.json'
    }).then(function successCallback(response) {
      $scope.pendingGames = response.data;
    }, function errorCallback(response) {
      $scope.pendingGamesError = true;
    });
  };

  $scope.startNewGame = function() {
    $http({
      method: 'POST',
      url: '/games.json'
    }).then(function successCallback(response) {
      $scope.newGame = response.data;
    }, function errorCallback(response) {
      $scope.newGameError = true;
    });
  };

  // Initialize
  $scope.getPendingGames();
}]);
