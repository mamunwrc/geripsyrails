geripsy.controller 'authCtrl', [
  '$scope'
  '$state'
  '$mdToast'
  'Auth'
  ($scope, $state, $mdToast, Auth)->
    console.log 'hello'
    $scope.login = ->
      Auth.login($scope.user).then (userResp) ->
          $state.go 'home'
        , (e) ->
          $mdToast.show
            template: '<md-toast><span class="md-toast-text">Invalid Username/Password</span></md-toast>'
            position: 'top left'
            hideDelay: 5000
          console.log e

]
