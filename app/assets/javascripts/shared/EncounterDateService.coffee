class EncounterDate
  constructor: (@dateFields) ->

  convertDateFields: (encData, fn) ->
    _.each @dateFields, (date) ->
      if sec = encData[date[0]]
        if _date = sec[date[1]]
          encData[date[0]][date[1]] = fn _date

  prepareEncDates: (encData, certified=false) ->
    # Parse all time fields into Date objects
    @convertDateFields encData, (date) -> momentu(date).toDate()

    unless certified or not encData.certification
      encData.certification.start_time = @asDate(encData.certification.start_time) if encData.certification.start_time
      encData.certification.end_time = @asDate(encData.certification.end_time) if encData.certification.end_time

  asDate: (time) =>
    return new Date() unless time
    if time.toString().match(/^\d+:\d+$/)
      parts = time.split(":")
      moment().set({hour: parts[0], minute: parts[1]}).toDate()
    else
      new Date(time)

geripsy.service 'EncounterDateService', -> EncounterDate

