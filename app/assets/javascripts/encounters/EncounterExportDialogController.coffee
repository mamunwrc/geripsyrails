@EncounterExportDialogController = ['$scope', '$mdDialog', ($scope, $mdDialog) ->
  $scope.hide = ->
    $mdDialog.hide()
  $scope.cancel = ->
    $mdDialog.cancel()
  $scope.submit = ->
    opt = $scope.encExport.opt
    $mdDialog.hide opt
]
