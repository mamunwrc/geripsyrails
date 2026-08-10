geripsy.controller 'HomeCtrl', ['$scope', 'Patient', ($scope, Patient) -> 
  populatePatients = ->
    return if $scope.populated
    $scope.populated = true

    if _.includes ["Usr::Provider", "Usr::Admin"], $scope.user.user_type
      $scope.isProvider = true
      $scope.searchURL = "/api/patients?with_tp=true"
      $scope.searchTransform = (patients) ->
        _.compact(_.map(patients, (p) ->
          if p2 = _.find $scope.globalPatients.patients, {id: p.id}
            _.tap _.cloneDeep(p2), (pat) ->
              pat.providers = (p.providers || []).join(", ")
              pat.tp_sessions = p.tp_sessions
              pat.next_tp = p.next_tp

              pat.alert_class =
                if p.tp_sessions is 0 and moment(p.next_tp).isBefore(new Date)
                  'red'
                else
                  'inherit'
        ))

  $scope.$watch 'globalPatients.patients', (val) ->
    populatePatients() if val
]

