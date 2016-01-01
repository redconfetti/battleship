angular.module('battleship').controller('GameController', ['$http', '$scope', 'Auth', function GameController($http, $scope, Auth) {

  var segregatePlayerGames = function(games, player) {
    var segregatedGames = {
      player: [],
      other: []
    }
    angular.forEach(games, function(game) {
      for (s = 0; s < game.player_game_states.length; s++) {
        if (game.player_game_states[s].player_id === player.id) {
          this.player.push(game);
        } else {
          this.other.push(game);
        }
      }
    }, segregatedGames);
    return segregatedGames;
  };

  $scope.getPendingGames = function() {
    $http({
      method: 'GET',
      url: '/games/pending.json'
    }).then(function successCallback(response) {
      $scope.pendingGames = response.data;
      Auth.currentUser().then(function(user) {
        $scope.pendingGames = segregatePlayerGames(response.data, user);
      }, function(error) {
        $scope.pendingGamesError = true;
      });
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
