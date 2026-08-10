ensureFieldName = (scope, attrs) ->
  unless scope.fieldName
    name = attrs.ngModel.split '.'
    name.shift()
    scope.fieldName = name.join '_'


dropDownController = ($scope, RefLookupService) ->

  getRefLookup = (keyprefix) ->
    RefLookupService.getRefLookup(keyprefix).then((resp)
      $scope.myDropDownData = resp.data
      $scope.myDropDownData
    )

  refRefLookupLocal = (keyprefix) ->
    @refData = RefLookupService.getRefLookupLocal(keyprefix)

    @refData


  $scope.myDropDownData = RefLookupService.getRefLookupLocal($scope.keyprefix)
#    refRefLookupLocal $scope.keyprefix
#

  $scope.$on( 'edit_done', () ->
    $scope.isEdit = false
  )

  $scope.$on( 'edit_cancel', () ->
    $scope.isEdit = false
  )

  $scope.$on( 'edit_begin', () ->
    $scope.isEdit = true

  )

  return

geripsy.directive 'facilityPos', ->
  scope:
    ngModel: '=ngModel'
  templateUrl: 'shared/views/_facility_pos.html'

geripsy.directive 'dropDownDirective', () ->
  scope: {
    errorMsg: '@'
    errorMessage: '@'
    label: '@'
    myData: '=ngModel'
    dataName: '@'
    keyprefix: '@'
    isRequired: '=ngRequired'
    onBlur: '=ngBlur'
    isEdit: '@'
  }
  restrict: 'AE'
  templateUrl: 'shared/views/_edit-dropdown.html'
  require: ['ngModel', 'ngMessages']
  controller: ['$scope', 'RefLookupService', ($scope, RefLookupService) ->
    dropDownController $scope, RefLookupService
  ]

geripsy.directive 'radioDirective', () ->
  scope: {
    errorMsg: '@'
    errorMessage: '@'
    label: '@'
    myData: '=ngModel'
    dataName: '@'
    keyprefix: '@'
    isRequired: '=ngRequired'
    onBlur: '=ngBlur'
    isEdit: '@'
  }
  #templateUrl: 'modules/shared/views/edit-radio.html'
  template: "<h1>LOL</h1>"
  require: ['ngModel', 'ngMessages']
  controller: ['$scope', 'RefLookupService', ($scope, RefLookupService) ->
    dropDownController $scope, RefLookupService
  ]

geripsy.directive 'gdBool', () ->
  scope: {
    errorMsg: '@'
    errorMessage: '@'
    label: '@'
    myData: '=ngModel'
    dataName: '@'
    isRequired: '=ngRequired'
    onBlur: '=ngBlur'
    isEdit: '='
    form: '='
    fieldName: '@'
    freetext: '='
  }
  templateUrl: 'shared/views/_edit-yesno.html'
  require: ['ngModel']
  link: (scope, el, attrs, ctrl) ->
    ensureFieldName(scope, attrs)

geripsy.directive 'gdText', ->
  restrict: 'E'
  scope:
    label: '@'
    myData: '=ngModel'
    fieldName: '@'
    isEdit: '='
    isRequired: '=ngRequired'
    onBlur: '=ngBlur'
    form: '='
    type: '@'
    placeholder: '@'
  templateUrl: 'shared/views/_edit-textarea.html'
  require: 'ngModel'
  link: (scope, el, attrs) ->
    ensureFieldName(scope, attrs)

geripsy.directive 'gdInput', () ->
  restrict: 'E'
  scope:
    errorObj:     '='
    errorMsg:     '@'
    errorMessage: '@'
    label:        '@'
    myData:       '=ngModel'
    fieldName:    '@'
    isEdit:       '='
    isRequired:   '=ngRequired'
    onBlur:       '=ngBlur'
    form:         '='
    type:         '@'
    placeholder:  '@'

  templateUrl: 'shared/views/_edit-input.html'
  require: 'ngModel'
  link: (scope, el, attrs, ctrl) ->
    scope.type ?= 'text'
    scope.minlength = attrs.minlength if attrs.minlength
    ensureFieldName(scope, attrs)

geripsy.directive 'gdDate', ->
  scope: {
    label: '@'
    myData: '=ngModel'
    dataName: '@'
    isRequired: '=ngRequired'
    onBlur: '=ngBlur'
    isEdit: '='
    form: '='
    isOpen: '=?'
    fieldName: '@'
  }
  templateUrl: 'shared/views/_edit-input-dateonly.html'
  require: 'ngModel'
  link: (scope, elem, attrs) ->
    scope.fixdate = (d) => scope.myData = momentu(d).toDate() if d
    scope.fixdate scope.myData
    ensureFieldName(scope, attrs)

geripsy.directive 'gdSimpleDate', ->
  scope: {
    label: '@'
    myData: '=ngModel'
    dataName: '@'
    isRequired: '=ngRequired'
    onBlur: '=ngBlur'
    isEdit: '='
    form: '='
    fieldName: '@'
  }
  templateUrl: 'shared/views/_edit-simple-date.html'
  require: 'ngModel'
  link: (scope, elem, attrs) ->
    ensureFieldName(scope, attrs)

geripsy.directive 'gdTime', ->
  scope:
    label: '@'
    myData: '=ngModel'
    fieldName: '@'
    isRequired: '=ngRequired'
    onBlur: '=ngBlur'
    isEdit: '='
    form: '='
  templateUrl: 'shared/views/_edit-time.html'
  require: 'ngModel'
  link: (scope, elem, attrs) ->
    ensureFieldName scope, attrs

geripsy.directive 'gdSimpleSelect', ->
  scope:
    label: '@'
    options: '='
    myData: '=ngModel'
    fieldName: '@'
    isEdit: '='
    isRequired: '=ngRequired'
  templateUrl: 'shared/views/_edit-simple-select.html'

geripsy.directive 'gdDropDown', () ->
  scope:
    errorMsg: '@'
    errorMessage: '@'
    label: '@'
    myData: '=ngModel'
    dataName: '@'
    keyprefix: '@'
    required: '='
    isEdit: '='
    ddType: '@'
    freetext: '='
    obj: '='
    ftModel: '='
    collection: '='
    form: '='
    isRequired: '=ngRequired'
    onBlur: '=ngBlur'
    onChange: '=ngChange'
    fieldName: '@'
    ftRequired: '='
    ftLabel: '@'

  link: (scope, elem, attrs) ->
    ensureFieldName(scope, attrs)
    scope.filterable = attrs.hasOwnProperty 'filterable'

  restrict: 'AE'
  templateUrl: 'shared/views/_edit-dropdown.html'
  controller: ['$scope', '$q', '$element', 'RefLookupService', 'IcdLookupService', ($scope, $q, $element, RefLookupService, IcdLookupService) ->
    CollectionController $scope, $q, $element, RefLookupService, IcdLookupService
  ]

geripsy.directive 'gdRadio', ->
  scope:
    label: '@'
    myData: '=ngModel'
    dataName: '@'
    keyprefix: '@'
    isEdit: '='
    ddType: '@'
    form: '='
    isRequired: '=ngRequired'
    onBlur: '=ngBlur'
    fieldName: '@'
  link: (scope, elem, attrs) ->
    scope.filterable = attrs.hasOwnProperty 'filterable'
  templateUrl: 'shared/views/_edit-radio.html'
  controller: ['$scope', '$q', '$element', 'RefLookupService', 'IcdLookupService', ($scope, $q, $element, RefLookupService, IcdLookupService) ->
    CollectionController $scope, $q, $element, RefLookupService, IcdLookupService
  ]
  link: (scope, elem, attrs) ->
    ensureFieldName(scope, attrs)

geripsy.directive 'gdDdMultiselect', ->
  scope:
    label: '@'
    myData: '=ngModel'
    dataName: '@'
    keyprefix: '@'
    isEdit: '='
    ddType: '@'
    freetext: '='
    ftModel: '='
    form: '='
    isRequired: '=ngRequired'
    onBlur: '=ngBlur'
    fieldName: '@'
    collection: '='

  link: (scope, elem, attrs) ->
    scope.filterable = attrs.hasOwnProperty 'filterable'
    ensureFieldName(scope, attrs)
  templateUrl: 'shared/views/_edit-multiselect.html'
  controller: ['$scope', '$q', '$element', 'RefLookupService', 'IcdLookupService', ($scope, $q, $element, RefLookupService, IcdLookupService) ->
    CollectionController $scope, $q, $element, RefLookupService, IcdLookupService
  ]

geripsy.directive 'gdCheckbox', ->
  scope:
    label: '@'
    myData: '=ngModel'
    dataName: '@'
    isEdit: '='
    freetext: '='
    ftModel: '='
    form: '='
    isRequired: '=ngRequired'
    fieldName: '@'

  templateUrl: 'shared/views/_edit-checkbox.html'
  link: (scope, elem, attrs) ->
    ensureFieldName(scope, attrs)

geripsy.directive 'focusOn', [ '$timeout', ($timeout)->
  restrict: 'A'
  link: (scope, elem, attrs) ->
    scope.$on attrs.focusOn, ->
      $timeout (-> elem[0].focus()), 100
]

geripsy.directive 'gdGotoPrev', ->
  scope:
    ngClick: '='
    theme: "="
  restrict: 'E'
  replace: true
  templateUrl: 'shared/views/_goto-prev.html'

geripsy.directive 'gdGotoNext', ->
  scope:
    ngClick: '='
    theme: "="
  restrict: 'E'
  replace: true
  templateUrl: 'shared/views/_goto-next.html'

CollectionController = ($scope, $q, $element, RefLookupService, IcdLookupService) ->
  lookup = ->
    if $scope.ddType is "icds"
      IcdLookupService.getIcds()
    else
      RefLookupService.getRefLookupLocal($scope.ddType, $scope.keyprefix)

  multiDisplayVals = (key) ->
    _.map key, (i) ->
      _.find($scope.collectionData, (j) -> j.keyname is i).keyvalue

  deferredDefs = (data) ->
    $scope.reverseLookup = (key) ->
      return unless key

      if $scope.ddType is "icds"
        $scope.myData
      else if typeof key is 'object' # check for array from multiselect
        multiDisplayVals(key).join ', '
      else
        try
          _.find(data, (i) -> i.keyname is key).keyvalue
        catch error
          console.error(error)

    if $scope.freetext
      ftobj =
        keyname: 'FREETEXT'
        keyvalue: 'Other'

      colFt = _.find(data, (i) -> i.keyname is 'FREETEXT')
      isMulti = angular.isArray $scope.myData
      if isMulti
        ft = _.find $scope.myData, (e) -> e.name is 'FREETEXT'
        colFt.freetext = ft.freetext if colFt and ft?.freetext

      ftobj.freetext = ft.freetext if ft?.freetext

      data.push ftobj unless colFt

  $scope.multiDisplayWithFreetext = ->
    _.map($scope.myData, (item) -> item.freetext or item.val).join '; '

  $scope.ddType ?= 'main'
  $scope.hasFreetext = (selections) ->
    _.find(selections, (selection) -> selection.name is 'FREETEXT')

  $scope.searchTerm
  $scope.clearSearchTerm = ->
    $scope.searchTerm = ''

  $element.find('input.dd-search-filter').on('keydown', (ev) -> ev.stopPropagation())

  $scope.$watch 'collection', (value) ->
    $scope.collectionData = value
    deferredDefs($scope.collectionData) if value

  $scope.$watch 'collectionData', (value) ->
    fetchData() if value is undefined and $scope.isEdit

  fetchData = ->
    lookup().then (data) ->
      $scope.collectionData = data
      deferredDefs data

  $scope.freetextObj = (arr) ->
    x = _.find arr, (field) -> field.name is "FREETEXT"
    x ?= {}

  # Need to copy over ALL data from $scope.myData
  # to allow freetext and other options
  #
  # Extending collectionData over current dataset
  # Should be caching properly but who knows
  extendedData = {}
  $scope.valForField = (item)->
    return unless item
    return extendedData[item.keyname] if extendedData[item.keyname]
    extendedData[item.keyname] = angular.extend({}, $scope.myData or {}, {val: item.keyvalue, name: item.keyname})
    extendedData[item.keyname]

