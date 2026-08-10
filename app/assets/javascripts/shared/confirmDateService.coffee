geripsy.factory 'ConfirmDateService', ['$mdDialog', '$q', ($mdDialog, $q) ->
  defaultLabel = "Yes, correct"
  raw          = (value) => momentu(value)
  format       = (value) => raw(value).format 'l'
  datestore    = []
  validations  = []
  items        = ->_.map datestore, (obj) -> [obj.label, obj.formatted].join(" ")
  globalValidations =
    future:
      msg: 'Date in future',
      fn: (date) ->
        $q (resolve) ->
          resolve momentu(date).isSameOrBefore(new Date, 'day')

  buildContent = ->
    _.compact([
      "<p>Are you sure the following info are correct?</p>",
      "<ul><li>",
      items().join("</li><li>"),
      "</li></ul>",
    ]).join("")

  setup = (contents) ->
    _.each _.compact(contents), (pair) =>
      datestore.push
        label: pair[0]
        formatted: format(pair[1])
        raw: raw(pair[1])

  showConfirm = (label) ->
    confirm = $mdDialog.confirm()
      .title('Confirmation Required')
      .htmlContent(buildContent())
      .ariaLabel("Confirm Dates")
      .ok(label)
      .cancel("No")
    $mdDialog.show(confirm)

  runValidation = (validation, date) ->
    validation.fn(date.raw).then (status) ->
      validity =
        if _.isObject(status)
          status.valid
        else
          status

      msg =
        if typeof validation.msg is 'function'
          validation.msg(status)
        else
          validation.msg

      $q.when
        valid: validity
        dateLabel: date.label
        message: msg

  confirmDates = (contents, confirmLabel=defaultLabel) ->
    datestore = []
    setup contents
    showConfirm confirmLabel

  confirmAndValidate = (opts) ->
    label = opts.label or defaultLabel
    datestore = []
    validations = opts.validations or _.keys(globalValidations)
    _.each opts.dates, (d) ->
      datestore.push
        label: d.label
        raw: raw(d.date)
        formatted: format(d.date)
        validation: d.validation
    showConfirm(label).then validate

  validationResults = ->
    results = []
    _.each datestore, (date) ->
      _.each validations, (validation) ->
        if _.isString(validation) and globalValidations[validation]
          validation = globalValidations[validation]
        else if not _.isPlainObject(validation)
          return false

        results.push runValidation(validation, date)

      if date.validation
        results.push runValidation(date.validation, date)

    $q.all(results)

  validate = ->
    validationResults().then (results) ->
      invalids = _.filter(results, (r) -> not r.valid)

      if invalids.length
        invalids = _.map invalids, (invalid) -> [invalid.dateLabel, invalid.message].join(" - ")
        content = _.compact([
          "<p>The following dates are invalid:</p>",
          "<ul><li>",
          invalids.join("</li><li>"),
          "</li></ul>"
        ]).join("")
        alert = $mdDialog.alert()
          .title('Invalid Dates')
          .htmlContent(content)
          .ariaLabel('Invalid Dates')
          .ok('OK')

        $mdDialog.show(alert).then -> $q.reject()



  return {
    confirm: confirmDates
    validate: confirmAndValidate
  }
]

