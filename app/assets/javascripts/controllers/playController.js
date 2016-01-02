angular.module('battleship').controller('PlayController', ['$http', '$routeParams', '$scope', 'Auth', function PlayController($http, $routeParams, $scope, Auth) {

  // Returns PlayerGameState for current player
  var findCurrentPlayerGameState = function(gameStates, currentUser) {
    var currentPlayerGameState = null;
    angular.forEach(gameStates, function(gameState) {
      if (gameState.player_id === currentUser.id) {
        currentPlayerGameState = gameState;
      }
    });
    return currentPlayerGameState;
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

  $scope.takeShot = function(x,y) {
    console.log('x: ' + x + ', y: ' + y);
  };

  $scope.loadPlayerGameState = function() {
    $http({
      method: 'GET',
      url: '/games/'+ $routeParams.gameId + '.json'
    }).then(function successCallback(response) {
      $scope.game = response.data;

      Auth.currentUser().then(function(user) {
        $scope.currentUser = user;
        $scope.playerGameState = findCurrentPlayerGameState($scope.game.player_game_states, $scope.currentUser)
        if ($scope.playerGameState === null) {
          $scope.displayError = 'Unable to identify current players data';
        }
      }, function(error) {
        $scope.displayError = 'Unable to load user profile';
      });
    }, function errorCallback(response) {
      $scope.displayError = 'Unable to load game state';
    });
  };

  $scope.loadPlayerGameState();
}]);
