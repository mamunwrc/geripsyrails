@SettingsDialogController = ['$scope', 'Auth', '$mdDialog', 'User', ($scope, Auth, $mdDialog, User) ->
  Auth.currentUser().then (user) ->
    $scope.user = user
    $scope.timezones = moment.tz.names().sort()
    angular.element("input.dd-search-filter").on 'keydown', (ev) -> ev.stopPropagation()

  $scope.hide = ->
    $mdDialog.hide()
  $scope.cancel = ->
    $mdDialog.cancel()
  $scope.submit = ->
    $scope.submitted = true
    User.update $scope.user
      .then((resp) ->
        $mdDialog.hide resp.data
      , (err) ->
        $mdDialog.hide err.data
      )

    console.log $scope.user
]
