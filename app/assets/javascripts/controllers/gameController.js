angular.module('battleship').controller('GameController', ['$http', '$scope', '$window', 'Auth', function GameController($http, $scope, $window, Auth) {

  // Segregates games by players current game and other players pending games
  var segregatePlayerGames = function(games, player) {
    var segregatedGames = {
      playersGames: [],
      othersGames: []
    }
    angular.forEach(games, function(game) {
      for (s = 0; s < game.player_game_states.length; s++) {
        if (game.player_game_states[s].player_id === player.id) {
          this.playersGames.push(game);
        } else {
          this.othersGames.push(game);
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

  $scope.getIncompleteGames = function() {
    $http({
      method: 'GET',
      url: '/games/incomplete.json'
    }).then(function successCallback(response) {
      $scope.incompleteGames = response.data;
      Auth.currentUser().then(function(user) {
        $scope.incompleteGames = segregatePlayerGames(response.data, user);
        if ($scope.incompleteGames.playersGames.length > 0) {
          setCurrentGame($scope.incompleteGames.playersGames[0]);
        }
      }, function(error) {
        $scope.displayError = 'Unable to load user profile';
      });
    }, function errorCallback(response) {
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

  $scope.joinGame = function(game) {
    $http({
      method: 'PUT',
      url: '/games/' + game.id + '/join.json'
    }).then(function successCallback(response) {
      setCurrentGame(response.data);
      $window.location.href = $scope.currentPlayerGame.playPath;
    }, function errorCallback(response) {
      $scope.displayError = 'Error creating new game';
    });
  };

  $scope.endPlayerGame = function() {
    $http({
      method: 'PUT',
      url: '/games/'+ $scope.currentPlayerGame.id + '/end.json'
    }).then(function successCallback(response) {
      $scope.getIncompleteGames();
    }, function errorCallback(response) {
      $scope.displayError = 'Error ending current game';
    });
  };

  // Initialize
  $scope.getIncompleteGames();
}]);
