@ScreeningsDialogController = ['$scope', '$mdDialog', 'ScreeningsService', ($scope, $mdDialog, screenings) ->
  $scope.screenings = screenings
  # FIXME make this generic for other screenings
  $scope.bcrs = {}
  $scope.hide = ->
    $mdDialog.hide()
  $scope.cancel = ->
    $mdDialog.cancel()
  $scope.submit = ->
    bcrs  = $scope.bcrs
    axes  = _.map([bcrs.axis1, bcrs.axis2, bcrs.axis3, bcrs.axis4], (axis) -> {val: Number(axis)})
    $mdDialog.hide axes
]
