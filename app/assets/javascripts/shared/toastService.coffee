geripsy.factory 'ToastService', ['$mdToast', ($mdToast) ->
  buildBodyFromString = (string) ->
    "<span class='md-toast' flex>#{string}</span>"

  buildBodyFromObject = (object) ->
    buildBodyFromArray _.reduce(object, ((msgs, errs, field) ->
      label = _.upperFirst(field).split("_").join(" ")
      msgs.concat([label + " " + errs.join(", ")])
    ), [])

  buildBodyFromArray = (array) ->
    _.map(array, (msg) -> buildBodyFromString(msg)).join("")

  buildTemplate = (msg) ->
    body = 
      if _.isString(msg)
        buildBodyFromString(msg)
      else if _.isArray(msg)
        buildBodyFromArray(msg)
      else if _.isObject(msg)
        buildBodyFromObject(msg)
      else
        console.error "Cant toast message %o", msg

    "<md-toast layout='column'>#{body}</md-toast>"

  return {
    display: (msgs) ->
      $mdToast.show
        template: buildTemplate msgs
        hideDelay: 5000
        position: 'top left'
  }
]
