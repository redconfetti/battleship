angular.module('battleship').controller('PlayController', ['$http', '$routeParams', '$scope', 'Auth', function PlayController($http, $routeParams, $scope, Auth) {

  var pushListenerRegistered = false;

  var loadPlayerGameState = function() {
    $http({
      method: 'GET',
      url: '/games/'+ $routeParams.gameId + '.json'
    }).then(function successCallback(response) {
      $scope.playerGameState = response.data;
      console.log($scope.playerGameState);
      if (!pushListenerRegistered) {
        registerPusherListener();
        pushListenerRegistered = true;
      }
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

  $scope.isCurrentTurn = function() {
    if ($scope.playerGameState && $scope.playerGameState.game) {
      return $scope.playerGameState.game.current_player_id === $scope.playerGameState.player_id;
    }
    return false;
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
      case 's':
        styles['grid-space-hit'] = true
        break;
    }
    return styles;
  }

  $scope.fireShot = function(xCoord, yCoord) {
    console.log('shot fired at X: ' + xCoord + ', Y: ' + yCoord);
    $http({
      method: 'PUT',
      url: '/games/'+ $routeParams.gameId + '/fire.json',
      data: {
        x: xCoord,
        y: yCoord
      }
    }).then(function successCallback(response) {
      console.log(response.data);
    }, function errorCallback(response) {
      $scope.displayError = 'Error firing shot';
    });
  };

  loadPlayerGameState();
}]);
