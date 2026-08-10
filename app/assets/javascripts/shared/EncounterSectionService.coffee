class EncForm
  constructor: ($timeout, $scope, opts={})->
    @sections = {}
    @scope = $scope
    @timeout = $timeout
    @validations = opts.validations or []
    @beforeSave = opts.beforeSave
    @submit = opts.submit
    @submitted = false
    @encPropName = opts.encPropName or 'encounter'

  addSection: (id, section) ->
    section.collection = @
    @sections[id] = new FormSection(id, section)

  sectionEdited: ->
    @scope.persist(uncertify: true) if @scope?

  getSections: ->
    @sections

  expandAll: ->
    angular.forEach @sections, (sec) -> sec.expanded = true

  closeAll: ->
    _.chain(@sections).filter((e) -> e.expanded).each((e) -> e.close()).value()

  validate: (form, validFn, invalidFn)->
    @form ?= form
    angular.forEach @sections, (sec) ->
      sec.expanded = true
      sec.validate()
      sec.expanded = !!sec.locked

  showErrors: ->
    _.chain(@sections).filter(valid: false).each((section) =>
      section.expanded = true
      @timeout ->
        section.validate()
        section.expanded = not section.valid or section.locked
    ).value()

  certifiable: ->
    _.every @sections, 'valid'

  certify: =>
    if @certifiable()
      msgs = _.map(@validations, (validation) =>
        if typeof validation is 'function'
          validation = validation(@scope[@encPropName])

        validation.run())
      if _.every(msgs, 'valid')
        @beforeSave().then @doSubmit
      else
        msgs = _.chain(msgs).map('msg').compact().value()
        @scope.Toast.display msgs

  doSubmit: =>
    @submitted = true
    @submit()


class FormSection
  constructor: (id, obj) ->
    @id         = id
    @number     = obj.number
    @heading    = obj.heading
    @partial    = obj.partial
    @fnid       = obj.fnid
    @locked     = !!obj.locked
    @expanded   = !!obj.locked
    @hide       = !!obj.hide
    @collection = obj.collection
    @valid      = false
    @validCB    = obj.validCB

  click: ->
    if @expanded
      @validateThenCloseAndPersist()
    else
      _.chain(@collection.sections).filter({expanded: true}).each( (expanded) ->
        expanded.validateThenCloseAndPersist()
      ).value()

      @collection.timeout => @expanded = true
      true

  validateThenCloseAndPersist: ->
    @validate()
    @expanded = !!@locked
    @collection.sectionEdited() if @form.$dirty and not @expanded

  close: ->
    @expanded = not @locked

  validate: (validFn, invalidFn) ->
    if typeof @validCB is "function"
      @valid = @validCB()
    else
      if @hide
        @valid = true
      else if @expanded
        @valid = @form.$valid

  revalidate: (event)=>
    @validate() if event?.target


geripsy.factory 'EncounterFormSectionBuilderService', ['$timeout', ($timeout) ->
  {
    buildForm: ($scope, sections, opts) ->
      _(new EncForm($timeout, $scope, opts))
        .tap (form) ->
          angular.forEach sections, (section) ->
            id = section.name
            delete section.name
            form.addSection id, section
        .value()
  }

]
