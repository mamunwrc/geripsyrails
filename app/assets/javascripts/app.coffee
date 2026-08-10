window.geripsy = angular.module 'geripsy', [
  'ngRaven'
  'ui.router'
  'templates'
  'ngResource'
  'ngSanitize'
  'ngMessages'
  'ngMaterial'
  'angularMoment'
  'ngAnimate'
  'ngCookies'
  'Devise'
  'duScroll'
  'mdPickers'
  'bgf.paginateAnything'
  'angular-loading-bar'
]

geripsy.config ['AuthProvider', 'AuthInterceptProvider', (AuthProvider, AuthInterceptProvider) ->
  AuthInterceptProvider.interceptAuth true
]

geripsy.run ['$rootScope', 'ToastService', 'GlobalHelpers', ($rootScope, ToastService, GlobalHelpers) ->
  $rootScope.Toast = ToastService
  $rootScope.helpers = GlobalHelpers
]

#geripsy.config ['$mdDateLocaleProvider', ($locale) ->
#  $locale.formatDate = (date, tz) ->
#    momentu(date).format 'L'
#]


geripsy.config ['$mdThemingProvider', ($mdThemingProvider) ->
  lightSteelBlueMap = $mdThemingProvider.extendPalette 'blue',
    '500': 'a6c2c9'
    '600': 'a6c2c9'
  lightCyanMap = $mdThemingProvider.extendPalette 'blue',
    '500': 'E0FFFF'
    '600': 'E0FFFF'
    'contrastDefaultColor': 'dark'
  powderBlueMap = $mdThemingProvider.extendPalette 'blue',
    '500': 'B0E0E6'
    '600': 'B0E0E6'
  cadetBlueMap = $mdThemingProvider.extendPalette 'blue',
    '500': '4f8593'
    '600': '4f8593'
  steelBlueMap = $mdThemingProvider.extendPalette 'blue',
    '500': '4682B4'
    '600': '4682B4'

  $mdThemingProvider.definePalette 'lightSteelBlue', lightSteelBlueMap
  $mdThemingProvider.definePalette 'lightCyan', lightCyanMap
  $mdThemingProvider.definePalette 'powderBlue', powderBlueMap
  $mdThemingProvider.definePalette 'cadetBlue', cadetBlueMap
  $mdThemingProvider.definePalette 'steelBlue', steelBlueMap

  $mdThemingProvider.theme('default').
    primaryPalette('cadetBlue').
    accentPalette('steelBlue').
    backgroundPalette('grey')

  $mdThemingProvider.theme('headerTheme').
    primaryPalette('powderBlue').
    accentPalette('cadetBlue').
    backgroundPalette('grey')

  $mdThemingProvider.theme('patientTheme').
    primaryPalette('lightSteelBlue').
    accentPalette('cadetBlue').
    backgroundPalette('grey')

  $mdThemingProvider.theme('providerTheme').
    primaryPalette('lightCyan').
    accentPalette('lightSteelBlue').
    backgroundPalette('orange')

]

geripsy.config ['$sceDelegateProvider', ($sceDelegateProvider) ->
  $sceDelegateProvider.resourceUrlWhitelist [
    'self'
    'https://raw.githubusercontent.com/**'
  ]
]

geripsy.config ['$mdIconProvider', ($mdIconProvider) ->
  $mdIconProvider
    .iconSet('action', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-action.svg', 24)
    .iconSet('alert', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-alert.svg', 24)
    .iconSet('av', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-av.svg', 24)
    .iconSet('communication', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-communication.svg', 24)
    .iconSet('content', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-content.svg', 24)
    .iconSet('device', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-device.svg', 24)
    .iconSet('editor', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-editor.svg', 24)
    .iconSet('file', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-file.svg', 24)
    .iconSet('hardware', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-hardware.svg', 24)
    .iconSet('image', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-image.svg', 24)
    .iconSet('maps', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-maps.svg', 24)
    .iconSet('navigation', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-navigation.svg', 24)
    .iconSet('notification', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-notification.svg', 24)
    .iconSet('social', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-social.svg', 24)
    .iconSet('toggle', 'https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-toggle.svg', 24)
    .iconSet('avatars', 'https://raw.githubusercontent.com/angular/material/master/docs/app/icons/avatar-icons.svg', 24)
    .defaultIconSet('https://raw.githubusercontent.com/google/material-design-icons/3.0.2/sprites/svg-sprite/svg-sprite-action.svg', 24)
]

geripsy.filter('ssn', () ->
  (number) ->
    if not angular.isDefined number
      ""
    else if number.match /^\s*$/
      number
    else
      number.replace(/(\d{3})(\d{2})(\d{4})/, '$1-$2-$3')
).filter('dateonly', () ->
  (datestring) ->
    momentu(datestring).format 'l'
).filter('dateonly2', () ->
  (datestring) ->
    momentu2(datestring).format 'l'
).filter('timeonly', ->
  (datestring) ->
    if datestring
      if datestring.toString().match(/^\d+:\d+$/)
        parts = datestring.split(":")
        moment().set({hour: parts[0], minute: parts[1]}).format('h:mma')
      else
        moment(datestring).format 'LT'
    else
      "INVALID"
).filter('status', ->
  (items, status) ->
    _.reject items, (item) -> item.status != status
).filter('phone', () ->
  (number) ->
    if not angular.isDefined number
      ""
    else if number.match /^\s*$/
      number
    else
      number.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3')
).filter('gender', () ->
  (input) ->
    input = input.val if typeof input is "object"
    input ?= ''

    {
      f: 'Female'
      female: 'Female'
      m: 'Male'
      male: 'Male'
    }[_.lowerCase(input)] or 'Unknown'

).filter('race', () ->
  (input) ->
    output = { W: 'White', B: 'Black', A: 'Asian', N: 'American Indian/Alaska Native', P: 'Pacific Islander', U: 'Unknown' }[input]
    if angular.isDefined(output) then output else "Unknown"
).filter('marital', () ->
  (input) ->
    output = { S: 'Single', D: 'Divorced', M: 'Married', W: 'Widowed', P: 'Separated', O: 'Other', U: 'Unknown' }[input]
    if angular.isDefined(output) then output else "Unknown"
).filter('yesno', () ->
  (input) ->
    output = { 1: 'Yes', 0: 'No', Y: 'Yes', N: 'No', U: 'Unknown' }[input]
    if angular.isDefined(output) then output else "Unknown"
).filter('randomize', ->
  _.memoize (input) ->
    Math.floor(Math.random() * input + 1) if input and input > 1
).filter('singular', ->
  (input) ->
    _.singularize input
).filter('fromnow', ->
  (datestring) ->
    moment(datestring).fromNow()
)
