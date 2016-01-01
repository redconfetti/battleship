angular.module('battleship').controller('GameController', ['$http', '$scope', '$window', 'Auth', function GameController($http, $scope, $window, Auth) {

  // Segregates games by players current game and other players pending games
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

  // Establishes current game and game play route path
  var setCurrentGame = function(game) {
    $scope.currentPlayerGame = game;
    $scope.currentPlayerGame.playPath = '/#/play/' + game.id;
  };

  $scope.endPlayerGame = function() {
    // $scope.currentPlayerGame;
    $http({
      method: 'PUT',
      url: '/games/'+ $scope.currentPlayerGame.id + '/end.json'
    }).then(function successCallback(response) {
      $scope.getPendingGames();
    }, function errorCallback(response) {
      $scope.displayError = 'Error ending current game';
    });
  };

  $scope.getPendingGames = function() {
    $http({
      method: 'GET',
      url: '/games/pending.json'
    }).then(function successCallback(response) {
      $scope.pendingGames = response.data;
      Auth.currentUser().then(function(user) {
        $scope.pendingGames = segregatePlayerGames(response.data, user);
        if ($scope.pendingGames.player.length > 0) {
          setCurrentGame($scope.pendingGames.player[0]);
        }
      }, function(error) {
        $scope.displayError = 'Unable to obtain current user';
      });
    }, function errorCallback(response) {
      $scope.pendingGamesError = true;
      $scope.displayError = 'Unable to retrieve pending games list';
    });
  };

  $scope.startNewGame = function() {
    $http({
      method: 'POST',
      url: '/games.json'
    }).then(function successCallback(response) {
      setCurrentGame(response.data);
      $window.location.href = $scope.currentPlayerGame.playPath;
    }, function errorCallback(response) {
      $scope.displayError = 'Error creating new game';
    });
  };

  // Initialize
  $scope.getPendingGames();
}]);
