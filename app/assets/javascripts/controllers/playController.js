angular.module('battleship').controller('PlayController', ['$http', '$routeParams', '$scope', 'Auth', function PlayController($http, $routeParams, $scope, Auth) {

  var pushListenerRegistered = false;

  var loadPlayerGameState = function() {
    $http({
      method: 'GET',
      url: '/games/'+ $routeParams.gameId + '.json'
    }).then(function successCallback(response) {
      $scope.playerGameState = response.data;
      if (!pushListenerRegistered) {
        registerPusherListener();
        pushListenerRegistered = true;
      }
      $scope.processingShot = false;
    }, function errorCallback(response) {
      $scope.displayError = 'Unable to load player game state';
    });
  };

  var registerPusherListener = function() {
    // Enable pusher logging - don't include this in production
    /*
    Pusher.log = function(message) {
      if (window.console && window.console.log) {
        window.console.log(message);
      }
    };
    */

    var pusher = new Pusher($scope.playerGameState.pusherKey, {
      encrypted: true
    });
    var channel = pusher.subscribe('game-' + $scope.playerGameState.game.id);
    channel.bind('updated', loadPlayerGameState);
  };

  var isCurrentTurn = function() {
    if ($scope.playerGameState && $scope.playerGameState.game) {
      return $scope.playerGameState.game.current_player_id === $scope.playerGameState.player_id;
    }
    return false;
  };

  var gameActive = function() {
    return ($scope.playerGameState && $scope.playerGameState.game && $scope.playerGameState.game.status !== 'complete') ? true : false;
  };

  $scope.enemyPlayerPresent = function() {
    return ($scope.playerGameState && $scope.playerGameState.enemy && $scope.playerGameState.enemy.id) ? true : false;
  };

  $scope.gamePrematurelyClosed = function() {
    return (!gameActive() && !$scope.isWinner() && !$scope.isLoser()) ? true : false;
  };

  $scope.awaitingOpponentShot = function() {
    return (!isCurrentTurn() && gameActive()) ? true : false;
  };

  $scope.playerControlsEnabled = function() {
    return (gameActive() && $scope.enemyPlayerPresent() && isCurrentTurn() && !$scope.processingShot) ? true : false;
  };

  $scope.isWinner = function() {
    return ($scope.enemyPlayerPresent() && $scope.playerGameState && $scope.playerGameState.stats && $scope.playerGameState.stats.enemyRemaining < 1) ? true : false;
  };

  $scope.isLoser = function() {
    return ($scope.playerGameState && $scope.playerGameState.stats && $scope.playerGameState.stats.remaining < 1) ? true : false;
  };

  // Specifies styles applied to grid spaces based on value
  $scope.gridSpaceStyle = function(spaceValue) {
    var styles = {}
    switch(spaceValue) {
      case 'w':
        styles['grid-space-water'] = true
        break;
      case 's':
        styles['grid-space-ship'] = true
        break;
      case 'h':
        styles['grid-space-hit'] = true
        break;
      case 'm':
        styles['grid-space-miss'] = true
        break;
    }
    return styles;
  }

  $scope.fireShot = function(xCoord, yCoord) {
    $scope.processingShot = true;
    $http({
      method: 'PUT',
      url: '/games/'+ $routeParams.gameId + '/fire.json',
      data: {
        x: xCoord,
        y: yCoord
      }
    }).then(function successCallback(response) {
      // console.log(response.data);
    }, function errorCallback(response) {
      $scope.displayError = 'Error firing shot';
    });
  };

  loadPlayerGameState();
}]);
