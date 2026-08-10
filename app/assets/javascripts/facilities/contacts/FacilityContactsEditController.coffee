@FacilityContactsEditController = [
  '$rootScope'
  '$scope'
  '$mdDialog'
  'contact'
  ($rootScope, $scope, $mdDialog, contact) ->
    $scope.contact = contact
    $scope.formats = ['pdf', 'docx']
    $scope.types   = ['partial', 'full']

    $scope.hide = ->
      $mdDialog.hide()
    $scope.cancel = ->
      $mdDialog.cancel()
    $scope.delete = ->
      $scope.contact.$delete (contact) ->
        contact.deleted = true
        $mdDialog.hide contact
      , (contact) ->
        console.log contact
        $rootScope.Toast.display contact.data

    $scope.submit = ->
      $scope.submitted = true
      meth = if contact.id then '$update' else '$save'
      $scope.contact[meth] (contact) ->
        $mdDialog.hide contact
        $rootScope.Toast.display ['Contact saved successfully']
      , (contact) ->
        $rootScope.Toast.display contact.data
        $scope.submitted = false
]
