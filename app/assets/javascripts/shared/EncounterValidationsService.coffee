class EncounterValidation
  constructor: (@encounter, @codes, @fn)->

  certTimes: =>
    start: @encounter.certification?.start_time
    end: @encounter.certification?.end_time

  timeDiff: =>
    certTimes = @certTimes()
    parseInt(moment.duration(moment(certTimes.end).diff(moment(certTimes.start))).asMinutes())

  run: =>
    if @codes.length and not _.includes(@codes, @encounter.cpt_encounter_code)
      return @valid()
    @fn.call(@)

  valid: ->
    {valid: true}

  invalid: (msg)->
    {valid: false, msg: msg}


geripsy.factory 'EncounterValidations', ->
  return {
    buildValidation: (encounter, codes..., fn) ->
      validation = new EncounterValidation(encounter, codes, fn)
  }

