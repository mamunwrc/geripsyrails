geripsy.directive 'tInfo', ->
  scope:
    label: '@'
    model: '=ngModel'
    field: '@'
    fieldName: '@'
    isEdit: '='
    noText: '@'
    explainText: '@'
  templateUrl: 'encounters/9611x/_background-info-qs.html'
  link: (scope, elem, attrs) ->
    scope.noText = attrs.noText or 'No'
    scope.explainText = attrs.explainText or 'Explain'
    scope.expOptional = attrs.hasOwnProperty 'expOptional'
    scope.optional = attrs.hasOwnProperty 'optional'
    scope.hasExpNo = attrs.hasOwnProperty 'expNo'

    extraExpText = if scope.expOptional then 'optional' else 'required'
    scope.explainText = scope.explainText + ' (' + extraExpText + ')'

geripsy.directive 'gdTsliderPrint', ->
  scope:
    label: '@'
    model: '=ngModel'
    modelContainer: '@'
    opts: '='

  templateUrl: 'encounters/9611x/_summary-sliders-print.html'

  link: (scope, elem, attrs) ->
    scope.model[attrs.modelContainer] or= {}

    scope.scores = for opt in scope.opts
      score = scope.model[attrs.modelContainer][opt.name] or 0
      printScore = switch
        when score is 0 then "0 (None)"
        when score < 4 then String(score) + " (Mild)"
        when score < 8 then String(score) + " (Moderate)"
        else String(score) + " (Severe)"

      {
        label: opt.name
        text: opt.text
        score: printScore
      }

geripsy.directive 'gdTslider', ->
  scope:
    label: '@'
    model: '=ngModel'
    modelContainer: '@'
    opts: '='
    isEdit: '='

  templateUrl: 'encounters/9611x/_summary-sliders.html'
  link: (scope, elem, attrs) ->
    scope.model[attrs.modelContainer] or= {}
    scope.disabled = "disabled" if attrs.hasOwnProperty 'disabled'

    scope.flexOffsetL = 30
    scope.baseScore   = 10

    scope.scores = for opt in scope.opts
      score   = scope.model[scope.modelContainer][opt.name] or 0
      flex    = (100 - scope.flexOffsetL - scope.baseScore) * (score/10)
      offsetR = 100 - scope.flexOffsetL - scope.baseScore - flex

      {
        label: opt.name
        text: opt.text
        score: score
        flex: flex
        flexOffsetR: offsetR
      }

geripsy.directive 'gdTestingHeader', ->
  restrict: 'E'
  scope:
    label: '@'
    note: '='
  templateUrl: 'encounters/9611x/_9611x-printed-header.html'
  link: (scope, elem, attrs) ->
    scope.header = scope.note.headers[attrs.code]
