geripsy.directive 'scroll', ['$timeout', ($timeout) -> #{{{
  scope:
    scroll: '='
  link: (scope) ->
    scope.$watch 'scroll', (v,o) ->
      return if v is "certification"
      console.log v,o, document.getElementById(scope.scroll)
      container = angular.element document.getElementById("content-container")
      scrollEl = angular.element document.getElementById(scope.scroll)
      $timeout -> container.scrollToElement(scrollEl)
]
#}}}

formSecs = #{{{
  TP: ->
    [
      name: 'info'
      number: 'I'
      heading: 'Patient Information'
      partial: 'encounters/_encounters-tp-information.html'
      fnid: 'referral'
    ,
      name: 'diagnosis'
      number: 'II'
      heading: 'Diagnosis and Prognosis'
      partial: 'encounters/_encounters-tp-diagnosis.html'
      fnid: 'diagnosis'
    ,
      name: 'necessity'
      number: 'III'
      heading: 'Target Symptoms and Treatment Plan Interventions'
      partial: 'encounters/_encounters-tp-problem-description.html'
      fnid: 'problem'
    ,
      name: 'treatment'
      number: 'IV'
      heading: 'Initial Recommendations and Plan'
      partial: 'encounters/_encounters-tp-treatment-plan.html'
      fnid: 'plan'
    ,
      name: 'goals'
      number: 'V'
      heading: 'Goals of Treatment'
      partial: 'encounters/_encounters-tp-goals.html'
      fnid: 'goals'
      validCB: ->
        @hasInput
    ,
      name: 'methods'
      number: 'VI'
      heading: 'Methods of Monitoring Outcomes'
      partial: 'encounters/_encounters-tp-methods.html'
      fnid: 'methods'
    ,
      name: 'certification'
      number: 'VII'
      heading: 'Certification of Goals'
      partial: 'encounters/_encounters-tp-certification.html'
      locked: true
    ]

  GBH1: ->
    [
      name: 'info'
      number: 'I'
      heading: 'Patient Information'
      partial: 'encounters/_encounters-gbh1-information.html'
      fnid: 'referral'
    ,
      name: 'diagnosis'
      number: 'II'
      heading: 'Assessment'
      partial: 'encounters/_encounters-tp-diagnosis.html'
      fnid: 'diagnosis'
    ,
      name: 'necessity'
      number: 'III'
      heading: 'Facilitating/Coordinating Treatment'
      partial: 'encounters/_encounters-gbh1-problem-description.html'
      fnid: 'problem'
    ,
      name: 'treatment'
      number: 'IV'
      heading: 'Behavioral Health Planning'
      partial: 'encounters/_encounters-gbh1-treatment-plan.html'
      fnid: 'plan'
    ,
      name: 'goals'
      number: 'V'
      heading: 'Behavioral Health Planning - Continuity of Care'
      partial: 'encounters/_encounters-gbh1-goals.html'
      fnid: 'goals'
      validCB: ->
        @hasInput
    ,
      name: 'methods'
      number: 'VI'
      heading: 'Rating Scale'
      partial: 'encounters/_encounters-tp-methods.html'
      fnid: 'methods'
    ,
      name: 'certification'
      number: 'VII'
      heading: 'Certification of Goals'
      partial: 'encounters/_encounters-gbh1-certification.html'
      locked: true
      validCB: ->
        @hasValidTime
    ]

  90791: ->
    [
      name: 'info'
      number: 'I'
      heading: 'Patient Information'
      partial: 'encounters/_patient-information.html'
      fnid: 'referral'
    ,
      name: 'mental'
      number: 'II'
      heading: 'Mental Status Examination'
      partial: 'encounters/_mental-status-examination.html'
      fnid: 'functional_status'
    ,
      name: 'history'
      number: 'III'
      heading: 'Background and History'
      partial: 'encounters/_background-history.html'
      fnid: 'background_history'
    ,
      name: 'necessity'
      number: 'IV'
      heading: 'Problem Description/Medical Necessity'
      partial: 'encounters/_problem-description.html'
      fnid: 'problem'
    ,
      name: 'diagnosis'
      number: 'V'
      heading: 'Diagnosis and Prognosis'
      partial: 'encounters/_diagnosis.html'
      fnid: 'diagnosis'
    ,
      name: 'treatment'
      number: 'VI'
      heading: 'Initial Recommendations and Treatment Plan'
      partial: 'encounters/_treatment-plan.html'
      hide: true
      fnid: 'plan'
    ,
      name: 'competency'
      number: 'VIb'
      heading: 'Competency/Capacity Summary'
      partial: 'encounters/_competency-summary.html'
      hide:  true
      fnid: 'competency'
    ,
      name: 'certification'
      number: 'VII'
      heading: 'Certification'
      locked: true
      partial: 'encounters/_encounters-certification.html'
      fnid: 'certification'
    ]

  90839: ->
    formSecs[90791]()
      .concat(
        [
          name: 'info'
          number: 'I'
          heading: 'Patient Information'
          partial: 'encounters/_90839_patient-information.html'
          fnid: 'referral'
        ,
          name: 'necessity'
          number: 'IV'
          heading: 'Problem Description/Medical Necessity'
          partial: 'encounters/_90839_problem-description.html'
          fnid: 'problem'
        ,
          name: 'treatment'
          number: 'VI'
          heading: 'Interventions'
          partial: 'encounters/_90839_treatment-plan.html'
          fnid: 'plan'
        ,
          name: 'certification'
          number: 'VII'
          heading: 'Certification'
          locked: true
          partial: 'encounters/_90839_certification.html'
          fnid: 'certification'
        ]
      )

  90832: ->
    [
      name: 'info'
      number: 'I'
      heading: 'Patient Information'
      partial: 'encounters/_fu-patient-information.html'
      fnid: 'referral'
    ,
      name: 'mental'
      number: 'II'
      heading: 'Functional Status'
      partial: 'encounters/_fu-functional-status.html'
      fnid: 'functional_status'
    ,
      name: 'history'
      number: 'III'
      heading: 'Background and History'
      partial: 'encounters/_fu-background-history.html'
      fnid: 'background_history'
    ,
      name: 'diagnosis'
      number: 'IV'
      heading: 'Diagnosis and Prognosis'
      partial: 'encounters/_fu-diagnosis.html'
      fnid: 'diagnosis'
    ,
      name: 'necessity'
      number: 'V'
      heading: 'Target Symptoms'
      partial: 'encounters/_fu-problem-description.html'
      fnid: 'problem'
    ,
      name: 'communication'
      number: 'VI'
      heading: 'Definitive Therapeutic Communication'
      partial: 'encounters/_fu-therapeutic-communication.html'
      fnid: 'therapeutic_communication'
    ,
      name: 'progress'
      number: 'VII'
      heading: 'Progress and Methods of Monitoring Outcomes'
      partial: 'encounters/_fu-progress.html'
      fnid: 'progress'
    ,
      name: 'certification'
      number: 'VIII'
      heading: 'Certification'
      locked: true
      partial: 'encounters/_fu-certification.html'
    ]

  96116: ->
    [
      name: 'info'
      number: 'I'
      heading: 'Patient Information'
      partial: 'encounters/9611x/_9611x-info.html'
      fnid: 'referral'
    ,
      name: 'background'
      number: 'II'
      heading: 'Background Information'
      partial: 'encounters/9611x/_9611x-background.html'
      fnid: 'background_history'
    ,
      name: 'summary'
      number: 'III'
      heading: 'Summary Profile'
      partial: 'encounters/9611x/_9611x-summary.html'
      fnid: 'functional_status'
    ,
      name: 'certification'
      number: 'IV'
      heading: 'Certification'
      locked: true
      partial: 'encounters/9611x/_9611x-certification.html'
    ]

  98966: ->
    [
      name: 'info'
      number: 'I'
      heading: 'Patient Information'
      partial: 'encounters/_fu-patient-information.html'
      fnid: 'referral'
    ,
      name: 'mental'
      number: 'II'
      heading: 'Functional Status'
      partial: 'encounters/_fu-functional-status.html'
      fnid: 'functional_status'
    ,
      name: 'history'
      number: 'III'
      heading: 'Background and History'
      partial: 'encounters/_fu-background-history.html'
      fnid: 'background_history'
    ,
      name: 'diagnosis'
      number: 'IV'
      heading: 'Diagnosis and Prognosis'
      partial: 'encounters/_fu-diagnosis.html'
      fnid: 'diagnosis'
    ,
      name: 'necessity'
      number: 'V'
      heading: 'Target Symptoms'
      partial: 'encounters/_fu-problem-description.html'
      fnid: 'problem'
    ,
      name: 'communication'
      number: 'VI'
      heading: 'Definitive Therapeutic Communication'
      partial: 'encounters/_fu-therapeutic-communication.html'
      fnid: 'therapeutic_communication'
    ,
      name: 'progress'
      number: 'VII'
      heading: 'Progress and Methods of Monitoring Outcomes'
      partial: 'encounters/_fu-progress.html'
      fnid: 'progress'
    ,
      name: 'certification'
      number: 'VIII'
      heading: 'Certification'
      locked: true
      partial: 'encounters/_fu-certification.html'
    ]
#}}}

window.Error.stackTraceLimit=100

geripsy.service "TestingService", -> #{{{
  status:
    xAxis: ["None", "Mild", "Moderate", "Severe"]
    yAxis: [
      "General intellectual ability"
      "Overall functional skills"
      "Language skills"
      "Attention-concentration skill"
      "Reasoning & judgment"
      "Short-term/working memory"
      "Long-term memory"
      "Motor speed"
      "Abstraction & problem solving"
      "Non-verbal & perceptual integrity"
    ]

  codes: [ 96116, 96130, 96132 ]

  srvcs: [
    name: 'dementia'
    text: "Is there a formal diagnosis of dementia in the medical record?"
  ,
    name: 'other'
    text: "Formal diagnosis of other organic brain condition?"
  ,
    name: "prev_testing"
    text: "Is there any record of previous psychological testing?"
  ,
    name: 'cog_func'
    text: "Are there any objective data in the medical record related to the following cognitive functions: Decision making; Social judgment; Memory; Reasoning; Non-verbal skills; Language skills"
  ,
    name: "emo_func"
    text: "Are there any objective data in the medical record related to the following emotional/behavioral functions: Anxiety, adjustment, depression, behavioral issuesAre there any objective data in the medical record related to the following emotional/behavioral functions: Anxiety, adjustment, depression, behavioral issues"
  ]

  impairments: [
    name: 'intability'
    text: "General intellectual ability"
  ,
    name: 'funcskill'
    text: "Overall functional skills"
  ,
    name: 'langskill'
    text: "Language skills"
  ,
    name: 'attskill'
    text: "Attention-concentration skill"
  ,
    name: 'reasoning'
    text: "Reasoning & judgment"
  ,
    name: 'memory'
    text: "Short-term/working memory"
  ,
    name: 'memory_long'
    text: 'Long-term memory'
  ,
    name: 'motorspeed'
    text: "Motor speed"
  ,
    name: 'probsolve'
    text: "Abstraction & problem solving"
  ,
    name: 'perceptint'
    text: "Non-verbal and perceptual integrity"
  ]

  interferences: [
    name: 'emo'
    text: "Emotional or psychological factors"
  ,
    name: 'org'
    text: "Organic factors"
  ,
    name: 'dementia'
    text: "Evidence of progressive dementia"
  ,
    name: 'mci'
    text: "Evidence of MCI (Mild cognitive impairment)"
  ]

  headers:
    96116: "Neurobehavioral status exam"
    96130: "Psychological testing report"
    96132: "Neuropsychological testing"

  hasCapacityComment: (note) ->
    val = note.functional_status.independent_capacity?.name
    _.includes(['full', 'limited_partial', 'none'], val) and
      note.functional_status.independent_capacity_note

  #}}}

geripsy.service 'encountersNavHelpers', ['$state', 'SessionStorage', ($state, SessionStorage) ->#{{{
  sharedDefaults: ($scope) ->
    $scope.initNavLists = (groups) ->
      encModes = {}
      patIds = {}
      encIds = _.map groups, (group) ->
        ids = _.map group, (enc) ->
          if enc[0]
            patIds["#{enc[0]}"] = enc[1] if enc[1]
            encModes["#{enc[0]}"] = enc[2]
            enc[0]
          else
            enc
        ids[-1..-1].concat(ids).concat(ids[0..0]).join(".")

      SessionStorage.set "encounters.nav_linked_enc_ids", JSON.stringify(encIds)
      SessionStorage.set "encounters.nav_linked_pat_ids", JSON.stringify(patIds)
      SessionStorage.set "encounters.nav_linked_enc_modes", JSON.stringify(encModes)
 
    $scope.initNavHelpers = ->
      encIds = JSON.parse(SessionStorage.get("encounters.nav_linked_enc_ids") || "[]")
      patIds = JSON.parse(SessionStorage.get("encounters.nav_linked_pat_ids") || "{}")
      encModes = JSON.parse(SessionStorage.get("encounters.nav_linked_enc_modes") || "{}")

      delim = ".#{$state.params.id}."
      prevId = undefined
      nextId = undefined
 
      if list = _.find(encIds, (list)-> _.includes(list, delim))
        parts = list.split(delim)
        prevId = parts[0].split(".").slice(-1)[0]
        nextId = parts[1].split(".")[0]

      goto = (id) ->
        return unless id
        curPatientId = parseInt($scope.globalPatients.currentPatient.id)
        tmpPatientId = parseInt(patIds[id]) || curPatientId
        $scope.globalPatients.currentEncReqPatientId = tmpPatientId

        target =
          if encModes[id] is 'P'
            'encounter.print'
          else if encModes[id] is 'E'
            'encounter.show'
          else
            $state.current.name

        if tmpPatientId isnt curPatientId
          $scope.globalPatients.setPatient tmpPatientId, false
          $state.go target, id: id
            .then -> $scope.globalPatients.setPatient curPatientId, false
        else
          $state.go target, id: id

      $scope.gotoPrev = () -> goto prevId
      $scope.gotoNext = () -> goto nextId
]#}}}

geripsy.service 'encounterHelpers', ['$state', '$mdDialog', '$mdMedia', '$q', 'ToastService', 'ConfirmDateService', 'SessionStorage', 'Patient', 'Encounter', 'RefLookupService', 'EncounterDateService', ($state, $mdDialog, $mdMedia, $q, ToastService, ConfirmDateService, sessionStorage, Patient, Encounter, RefLookup, EncounterDateService) ->#{{{
  referralLookup = (type, encounter) ->
    encounter.referral?.reasons and _.find(encounter.referral.reasons, (r) -> r.name is type)

  @patient = ->
    patientData = sessionStorage.get 'patient'
    patient = JSON.parse patientData
    resPat = new Patient
    _.merge resPat, patient
    resPat

  @handleInactive = (patient) ->
    if patient.status.val is 'inactive' or patient.status is 'inactive'
      ToastService.display ['Patient must be active to do that']
      $state.go 'encounters', {}, {reload: true}
      true

  @sharedDefaults = ($scope, $state, $timeout, Facility) ->
    # GRAB CERT PHRASES FROM SERVER
    Encounter.certs {}, (certs) =>
      $scope.certTexts = certs

    $scope.formTemplate = "encounters/_encounters-edit.html"
    $scope.editRoute = "encounter.edit({id: myEncounter.id})"
    $scope.sectionHome = "encounters"

    $scope.therapeuticFocus = (type) ->
      $scope.multiExists type, 'therapeutic_communication', 'therapeutic_focus'

    $scope.multiExists = (val, section, entry) ->
      e = $scope.myEncounter
      return false unless (section = e[section]) and (entry=section[entry])

      _.includes _.map(entry, 'name'), val

    $scope.competencyFreetext = ->
      if $scope.evaluationSelected()
        $scope.myEncounter.referral.reasons[1].freetext
      else
        $scope.myEncounter.referral.reasons[0].freetext


    $scope.evaluationSelected = ->
      referralLookup "1", $scope.myEncounter

    $scope.competencySelected = ->
      referralLookup "2", $scope.myEncounter


    $scope.formFor =
      90791: $scope.formsec
      90832: $scope.fuFormsec

    editOnly = ->
      $scope.$watch 'myEncounter.referral.hiatus_reason', (newval, oldval) -> #{{{
        return unless newval
        $scope.showHiatusDate = newval?.name is 'hospitalized' or newval?.name is 'transferred'
        $scope.openHiatusDate = $scope.showHiatusDate and newval?.name isnt oldval?.name
        $scope.myEncounter.referral.hiatus_date = undefined unless $scope.showHiatusDate
      #}}}

      $scope.$watch 'myEncounter.background_history.gdr_plan', (newval, oldval) -> #{{{
        return unless newval
        console.log newval
        $scope.openGDRDate = newval?.name is 'Y' and newval?.name isnt oldval?.name
      #}}}

      if $scope.myEncounter.cpt_encounter_code is "96116" #{{{
        # display freetext boxes when certain
        # options selected in info section
        $scope.$watch 'myEncounter.referral.services_conducted', (newval, oldval) -> #{{{
          newval = newval or []

          $scope.__hasWais  = _.find newval, (opt) -> opt.name is "7"
          $scope.__hasGraph = _.find newval, (opt) -> opt.name is "10"
        #}}}
      #}}}

      # Remove IC problems if NO is selected
      # Workaround for the change of IC opts to multiselect
      $scope.$watch 'myEncounter.functional_status.interactive_complexity.name', (newname, oldname) ->
        if newname is 'N'
          delete $scope.myEncounter.functional_status.interactive_complexity.problems

        if newname and newname isnt oldname
          $timeout =>
            $scope.formsec.sections.mental.validate()

            # Need to revalidate service provided if 908xx
            if $scope.encresource.cpt_encounter_code is "90832"
              $scope.formsec.sections.communication.expanded = true
              $scope.formsec.sections.communication.validate()

      $scope.$watch 'myEncounter.background_history.hist_mental_ill', (newVal, oldVal) ->
        return if not newVal or (newVal.length is 1 and newVal[0].name is 'NONE')

        bghist = $scope.myEncounter.background_history

        # if 'none' selected, disallow any other selections
        if _.find newVal, {name: 'NONE'}
          bghist.hist_mental_ill = _.filter bghist.hist_mental_ill, {name: 'NONE'}
          return

        # only one of PSYHOSP, HISTNOHOSP can be selected
        hasPsyhosp = _.find oldVal, {name: 'PSYHOSP'}
        hasHistNoHosp = _.find oldVal, {name: 'HISTNOHOSP'}
        if hasPsyhosp and _.find(newVal, {name: 'HISTNOHOSP'})
          bghist.hist_mental_ill = _.reject bghist.hist_mental_ill, {name: 'PSYHOSP'}
          return

        if hasHistNoHosp and _.find(newVal, {name: 'PSYHOSP'})
          bghist.hist_mental_ill = _.reject bghist.hist_mental_ill, {name: 'HISTNOHOSP'}
          return



      $scope.$watch 'myEncounter.referral.reasons', (newVal, oldVal) ->
        if newVal
          treatment  = $scope.formsec.sections.treatment
          competency = $scope.formsec.sections.competency
          return unless treatment and competency

          treatment.hide  = not _.find newVal, (o) -> o.name is "1"
          competency.hide = not _.find newVal, (o) -> o.name is "2"

          treatment.validate()
          competency.validate()

          competency.number = if treatment.hide then 'VI' else 'VIb'

      $scope.$watch 'myEncounter.functional_status.respondtreatment_desc', (newVal, oldVal) ->
        return unless newVal

        $scope.myEncounter.plan ?= {}
        $scope.therapyRecommendable = newVal.name isnt "2"

        if newVal.name is "2"
          $scope.myEncounter.plan.amount_of_service = {name: "4", val: "Not recommended" }

        if newVal.name isnt "FREETEXT"
          $scope.myEncounter.functional_status.respondtreatment_desc.freetext = undefined

      # BEGIN SCREENING LINK STUFF
      screeningLinkUpdate = (linkVal) ->
        # Ignore previous screening(s) if new value selected
        if $scope.SCREENING_RESET
          $scope.screenings_params = undefined
          $scope.myEncounter.functional_status.cognitive_screen = undefined
          $scope.myEncounter.functional_status.respondtreatment_desc = undefined
        else
          # Don't reset the first time around (saved screening data)
          $scope.SCREENING_RESET = true

        links = $scope.respondtreatmentLinks
        if link = links.options[linkVal.name]
          links.display = true
          links.url = link.url
          links.title = link.title

        else
          links.display = false

      $scope.$watch 'myEncounter.functional_status.respondtreatment', (newVal, oldVal) ->
        return unless newVal and newVal?.name isnt oldVal?.name

        screeningLinkUpdate newVal

      $scope.therapyRecommendable = true
      $scope.respondtreatmentLinks =
        display: false
        options:
          1:
            title: "New BCRS"
            url: '#bcrs'
          2:
            url: "http://www.dementia-assessment.com.au/global/cdr_scale.pdf"
            title: 'http://www.dementia-assessment.com.au/global/cdr_scale.pdf'
          3:
            title: "http://www.dementiatoday.com/wp-content/uploads/2012/06/MiniMentalStateExamination.pdf"
            url: "http://www.dementiatoday.com/wp-content/uploads/2012/06/MiniMentalStateExamination.pdf"
          4:
            title: "http://www.mocatest.org/wp-content/uploads/2015/03/Montreal-cognitive-assessment-Basic-English-FINAL-VERSION-4-June-2014.pdf"
            url: "http://www.mocatest.org/wp-content/uploads/2015/03/Montreal-cognitive-assessment-Basic-English-FINAL-VERSION-4-June-2014.pdf"
          5:
            title: "http://www.mirecc.va.gov/visn21/pdf/GDS_Basic_Package.pdf"
            url: "http://www.mirecc.va.gov/visn21/pdf/GDS_Basic_Package.pdf"

      # trigger screening link updater if exists
      if linkVal = $scope.myEncounter.functional_status?.respondtreatment
        screeningLinkUpdate linkVal
      #END SCREENING LINK STUFF

      $scope.doScreening = (ev)->
        type = $scope.respondtreatmentLinks.url[1..-1]
        fullScreen = $mdMedia('sm') or $mdMedia('xs')
        $mdDialog.show
          controller: ScreeningsDialogController
          controllerAs: 'ctrl'
          templateUrl: "encounters/screenings/_#{type}.html"
          parent: angular.element document.body
          targetEvent: ev
          clickOutsideToClose: true
          fullscreen: fullScreen
        .then((axes) ->
            val   = _.sumBy axes, 'val'
            total = Math.floor val / 4
            console.log axes
            $scope.myEncounter.functional_status.cognitive_screen = total
            $scope.screenings_params = [
              {
                screening_type: type
                axes: axes
              }
            ]

            RefLookup.getRefLookupLocal('encounter', 'RESPNDTREATMNTDESC').then (data) ->
              descs =
                one:
                  val: data[0].keyvalue
                  name: data[0].keyname
                two:
                  val: data[1].keyvalue
                  name: data[1].keyname
              $scope.myEncounter.functional_status.respondtreatment_desc = if total in [1..4] then descs.one else descs.two
          , ->
            console.log "screening dialog canceled"
        )

        console.log type

    editOnly() if $scope.isEditing

    $scope.mdNames = []

    $scope.$watch 'myPatient', (val) ->
      return unless val?.facility?.id
      $scope.$broadcast 'reload-drs'

    $scope.$on 'reload-drs', ->
      Facility.get id: $scope.myPatient.facility.id, (fac) ->
        $scope.mdNames = _.map fac.doctors, (doc) ->
          keyname: doc.id
          keyvalue: doc.name

        $scope.mdNames.push
          keyname: 'FREETEXT'
          keyvalue: 'Add new doctor'

    $scope.confirmUntimed = =>
      enc = $scope.myEncounter
      code = enc.cpt_encounter_code
      return unless code is '90832'

      start = enc.certification?.start_time
      end = enc.certification?.end_time
      diff = parseInt(moment.duration(moment(end).diff(moment(start))).asMinutes())
      service_conducted = enc.therapeutic_communication?.service_conducted
      service = service_conducted?.name
      return unless service is '7' and diff > 15

      content =
        _.compact([
          "<p>You have chosen 'Untimed Psychotherapy' even though the time spent in your session qualifies for a billed session.</p>",
          "<p>Are you sure you want this to remain as untimed?</p>"
        ]).join('')

      confirm = $mdDialog.confirm()
        .title 'Confirm Untimed Selection'
        .htmlContent content
        .ariaLabel 'untimed confirmation'
        .ok 'Yes'
        .cancel 'No - change CPT code'
      $mdDialog.show(confirm).then(()=>
        console.log 'confirmed!'
      , ()=>
        $scope.formsec.sections.communication.expanded = true
        $q.reject()
      )

    $scope.confirmDates = () => 
      code = $scope.myEncounter.cpt_encounter_code
      typed = (types...) => _.find types, (t) -> code == t
      date = (field) => $scope.myEncounter.referral[field]
      dupableEncs = ['TP']

      fields = []
      dupDosField =
        label: 'Date of Service'
        date: date('service_date')
      if not _.includes(dupableEncs, code)
        dupDosField.validation =
          msg: 'Date of Service Duplicated'
          fn: (date) ->
            defer = $q.defer()
            if code is '90832'
              code = $scope.myEncounter.therapeutic_communication?.service_conducted?.name
            Encounter.dup_check {patient_id: $scope.myPatient.id, date: date, cpt: code, enc: $scope.myEncounter.id}, (resp) ->
              defer.resolve resp.is_dup is 'no'

            defer.promise

      fields.push dupDosField

      if typed('90791', 'TP')
        fields.push
          label: 'Date of MD Order'
          date: date('order_date')

      ConfirmDateService.validate
        dates: fields
        label: 'Yes, correct - approved for billing'
        validations: ['future']

    $scope.onSubmitFailure = (rs) =>
      message =
        if rs.status == 409
          "Encounter already certified"
        else
          rs.data || rs.errors || "#{rs.status} #{rs.statusText}"

      # Reset DOS if DOS invalid
      if rs.data?.date_of_service and $scope.formsec
        $scope.myEncounter.referral.service_date = undefined
        $scope.formsec.sections.info.expanded = true
        $scope.formsec.sections.info.valid = false
        $scope.formsec.showErrors()
        $timeout ->
          $("gd-date[field-name='service_date'] md-datepicker").triggerHandler 'blur'

      $scope.Toast.display message
      $scope.encresource.certify = false
      $scope.formsec.submitted = false

    dateFields = [['referral', 'order_date'], ['referral', 'service_date'], ['referral', 'hiatus_date']]
    $scope.dateConverter = new EncounterDateService(dateFields)

    $scope.addNewMd = (newMd) ->
      return unless newMd
      unless _.includes(_.map($scope.mdNames, 'keyvalue'), newMd.val)
        lastMd = $scope.mdNames.pop()
        $scope.mdNames.push keyname: newMd.name, keyvalue: newMd.val
        _.sortBy $scope.mdNames, 'keyvalue'
        $scope.mdNames.push lastMd

    $scope.persist ?= (opts = {}) =>
      $scope.encresource.incident_to_provider_id = null
      if $scope.encresource.incident_to_provider && $scope.encresource.incident_to_provider.name
        $scope.encresource.incident_to_provider_id = $scope.encresource.incident_to_provider.name

      if opts.uncertify
        $scope.encresource.certify = false
        $scope.encresource.certification?.sign_date = undefined

      $scope.encresource.encounter = {}
      _.forEach $scope.encresource.data_fields, (f) ->
        $scope.encresource.encounter[f] = _.cloneDeep $scope.myEncounter[f]

      if posCode = $scope.myEncounter.facility_pos_code
        $scope.encresource.encounter.facility_pos_code = posCode

      if $scope.myEncounter.hasOwnProperty 'unbilled'
        $scope.encresource.encounter.unbilled = $scope.myEncounter.unbilled

      $scope.dateConverter.convertDateFields $scope.encresource.encounter, (date) ->
        momentu(date).toDate().toJSON()

      if $scope.screenings_params
        $scope.encresource.encounter.screenings_attributes = $scope.screenings_params

      if date = $scope.encresource.encounter.certification?.start_time
        $scope.encresource.encounter.certification.tz_offset_mins = moment(date).utcOffset()

      $scope.encresource.$update({id: $scope.encresource.id, patient_id: $scope.myPatient.id})
        .then (rs)->
          _.forEach $scope.encresource.data_fields, (f) ->
            $scope.myEncounter[f] = $scope.encresource[f]
          $scope.dateConverter.prepareEncDates $scope.myEncounter, !!$scope.encresource.signed_on
          $scope.addNewMd $scope.myEncounter.referral?.md_name
          true
        .catch($scope.onSubmitFailure)

    # TREATMENT PLAN SPECIFIC STUFF
    if $scope.myEncounter.cpt_encounter_code is "TP"
      $scope.monitoringOutcomes = {}
      $scope.getLookup('encounter', 'TPMETHODS').then (data) ->
        _meths = _.map(data, (o) -> {name: o.keyname, val: o.keyvalue, selected: false})
        _.each _meths, (meth) ->
          $scope.monitoringOutcomes[meth.name] = meth
          @

        $scope.$watch 'myEncounter.tp_methods.methods', (newVal, oldVal) ->
          _.each $scope.monitoringOutcomes, (meth) ->
            meth.selected = !!_.find newVal, (val) -> val.name is meth.name
            @

    @



  @wrapPayload = ($scope) ->
    secs = ['functional_status', 'introduction', 'problem', 'diagnosis', 'referral', 'plan', 'competency', 'background_history', 'progress', 'therapeutic_communication', 'certification', 'methods', 'goals']
    enc = $scope.myEncounter

    $scope.myEncounter.encounter = {}
    _.each secs, (sec) ->
      return unless enc[sec]
      enc.encounter[sec] = enc[sec]
      delete enc[sec]

  @
] #}}}

geripsy.controller 'encountersController', [ #{{{
  '$scope'
  '$http'
  '$state'
  '$timeout'
  'Encounter'
  'SessionStorage'
  'RefLookupService'
  'Patient'
  'patient'
  'encountersNavHelpers'
  ($scope, $http, $state, $timeout, Encounter, sessionStorage, refLookupService, Patient, patient, encountersNavHelpers) ->
    #if _.includes ["Usr::Admin", "Usr::Reviewer"], $scope.user.user_type
    #  $state.go 'encountersFilter'

    $scope.canManage = false
    $http.get($state.href('encountersCanManage')).then (response) ->
      $scope.canManage = response.data.authorized

    $scope.myPatient  = patient
    $scope.title = "Encounters for patient: #{patient.fullName()}"

    $scope.encounters =
      groups: ["signed", "unsigned", "treatment"]
      links: {}
      unsigned: []
      signed: []
      treatment: []
      listTitle: (group) ->
        {
          signed: "Signed Notes"
          unsigned: "Unsigned Notes"
          treatment: "Treatment Plans"
        }[group]
      filters:
        cpt: null
        from: null
        simple: true
      cpts: ['90791', '90832', '90853', '90839', '96116', '98966']
      dates: [
        {
          label: 'this week'
          val: '7'
        },
        {
          label: 'this month'
          val: '30'
        },
        {
          label: 'this year'
          val: '365'
        }
      ]
      listRoute: (group) ->
        params =
          _(@filters).omitBy(_.isNull).toPairs().map( (param) -> param.join('=') ).value().join("&")

        {
          signed: "/api/patients/#{patient.id}/encounters/signed?"
          unsigned: "/api/patients/#{patient.id}/encounters/unsigned?"
          treatment: "/api/patients/#{patient.id}/encounters/treatment?"
        }[group] + params
      routeFor: (enc) ->
        if enc.certified
          'encounter.print({id: item.id})'
        else
          'encounter.show({id: item.id})'
      searchTransform: (result, headers) ->
        if _.has(result, 'data')
          $timeout ->
            $scope.initNavLists _.values($scope.encounters.links)
          , 1000
          if _.has(result, 'meta')
            $scope.encounters.links[result.meta.type] = result.meta.links
          result.data
        else
          []

    $scope.setCreateable 'Enc::Encounter'

    $scope.deleteEncounter = (enc) ->
      date = new Date(enc.service_date)
      message = "Are you sure you want to delete encounter type " + enc.encounter_type + " with service date '" + date.toLocaleDateString() + "'"
      result = confirm(message)
      if result == true
        href = $state.href('encountersApi', {patient_id: enc.patient_id, id: enc.id})
        $http.delete(href).then (response) ->
          angular.forEach $scope.encounters.groups, (group) ->
            index = $scope.encounters[group].findIndex (encounter) ->
              encounter.id == enc.id
            if index >= 0
              $scope.encounters[group].splice(index, 1)

    $scope.resetPagination = ->
      $scope.global.pagination.page = 0

    encountersNavHelpers.sharedDefaults $scope

    $timeout ->
      # HACK to avoid false reloading as we are broadcasting 'patient-scope-changed'
      # too liberally currently... ideally, we should only broadcast
      # 'patient-scope-changed' ONLY on user-trigger events
      $scope.$on 'patient-scope-changed', (event, args) ->
        $state.go 'encounters', {}, reload: true
    , 2001
] #}}}

geripsy.controller "encountersFilterController", [ #{{{
  '$scope'
  '$state'
  '$mdDialog'
  '$mdMedia'
  'SessionStorage'
  'Encounter'
  'Patient'
  'Provider'
  'Facility'
  'Insurance'
  'RefLookupService'
  'encountersNavHelpers'
  ($scope, $state, $mdDialog, $mdMedia, session, Encounter, Patient, Provider, Facility, Insurance, RefLookupService, encountersNavHelpers) ->
    $scope.isTreatmentPlan = !!$state.current.data.treatmentPlan;

    # allow filter input to work
    angular.element('input.dd-search-filter').on('keydown', (ev) -> ev.stopPropagation())
    $scope.$watch 'patientFilter', (val) ->
      return unless val
      $scope.searchObj.patient = []

    objectify = (collection, key, val) ->
      _.map collection, (item) ->
        keyname: item[key]
        keyvalue: item[val]

    $scope.encounters = []
    $scope.patients   = []
    $scope.providers  = []
    $scope.facilities = []
    $scope.insurances = []
    $scope.categories = []

    ''

    lookupMap =
      encounter:
        diagnosis_diagnoses: 'ICD'
        diagnosis_prognoses: 'PROGNOSIS'
        functional_status_descriptions: 'RESPNDTREATMNTDESC'
        functional_status_insights: 'INSIGHT'
        functional_status_intabilities: 'INTABILITY'
        functional_status_interactive_complexities: 'REASONINTEACTVCOMPLXTY'
        functional_status_motivations: 'MOTIVATION'
        functional_status_reasonings: 'REASONING'
        functional_status_recalls: 'RECALL'
        functional_status_severities: 'CGIS'
        functional_status_thought_processes: 'THOUGHTPR'
        group_data_interventions_therapeutic_factors: 'THERAPEUTICFACTORS'
        plan_amount_of_services: 'PLANRECOMMENDED'
        plan_crisis_mobilizations: 'CRISISMOBILIZATION'
        plan_crisis_psychotherapies: 'CRISISPSYCH'
        plan_crisis_recommendations: 'CRISISRECS'
        plan_crisis_risk_assessments: 'CRISISRISK'
        plan_durations: 'PLANDURATION'
        plan_frequencies: 'PLANFREQUENCY'
        plan_other_services: 'PLANOTHERSERVICES'
        problem_frequencies: 'PROBLEMFREQ'
        problem_intensities: 'PROBLEMINTENSITY'
        problem_major_target_symptoms: 'MAJORTARGETSYM'
        problem_onsets: 'PROBLEMONSET'
        problem_others: 'PROBLEMSOTHER'
        problem_precipitating_stressors: 'PRECIPSTRESSORS'
        problem_staff_impressions: 'STAFFIMPRESSION'
        problem_tp_interventions: 'GBH1INTERVENTIONS'
        progress_cgiis: 'CGII'
        progress_frequencies: 'PLANFREQUENCY'
        progress_monitoring_mechanisms: 'MONITORMECH'
        progress_sessions: 'SESSIONPROG'
        referral_hiatus_reasons: 'HAS90791THISYEAR'
        referral_initiators: 'REFINITIATOR'
        referral_medical_necessities: 'MEDICALNECESSITY'
        referral_reasons: 'REFREASONS'
        therapeutic_communication_attempted_tos: 'THERAPYATTEMPT'
        therapeutic_communication_modalities: 'MODALITIES'
        tp_methods_methods: 'TPMETHODS'
      main:
        background_history_birth_places: 'BIRTHPLACE'
        background_history_education_statuses: 'EDUSTATUS'
        background_history_family_backgrounds: 'FAMILYBACKGRND'
        background_history_family_statuses: 'FAMILYSTATUS'
        background_history_marital_statuses: 'MARITALSTATUS'
        background_history_mental_illnesses: 'HISTMETNALILL'
        background_history_occupational_statuses: 'OCCUPATION'
        background_history_raised_bys: 'RAISEDBY'
        background_history_religious_statuses: 'RELIGIOUSSTATUS'

    # initialize scope arrays
    _.each lookupMap, (subMaps, group) ->
      _.each subMaps, (prefix, array) ->
        $scope[array] = []

    # perform lookups
    _.each lookupMap, (subMaps, group) ->
      _.each subMaps, (prefix, array) ->
        RefLookupService.getRefLookupLocal(group, prefix).then (data) ->
          $scope[array] = data

    Encounter.md_names (data)-> $scope.referral_md_names = objectify(data, 'name', 'val')
    Patient.query {simple: true}, (patients)-> $scope.patients = _.map patients, (patient) ->
      keyname: patient.id
      keyvalue: [patient.last_name, patient.first_name].join ', '
    Provider.query {simple: true}, (providers)-> $scope.providers = objectify providers, 'id', 'full_name'
    Facility.query {simple: true}, (facilities)-> $scope.facilities = objectify facilities, 'id', 'name'
    Insurance.index {simple: true}, (insurances)->$scope.insurances = objectify insurances, 'id', 'name'

    $scope.routeFor = (enc) =>
      if enc.certified
        "encounter.print({id: #{enc.id}})"
      else
        "encounter.show({id: #{enc.id}})"

    $scope.cpt_codes  = [
        keyname: 90791
        keyvalue: 90791
      ,
        keyname: 90832
        keyvalue: 90832
      ,
        keyname: 90834
        keyvalue: 90834
      ,
        keyname: 90837
        keyvalue: 90837
      ,
        keyname: 90839
        keyvalue: 90839
      ,
        keyname: 90846
        keyvalue: 90846
      ,
        keyname: 90847
        keyvalue: 90847
      ,
        keyname: 90853
        keyvalue: 90853
      ,
        keyname: 96116
        keyvalue: '961xx'
      ,
        keyname: 'TP'
        keyvalue: 'Treatment Plan'
      ,
        keyname: 'GBH1'
        keyvalue: 'General Behavioral Health Integration'
      ,
        keyname: 98966
        keyvalue: 98966
      ,
        keyname: 98967
        keyvalue: 98967
      ,
        keyname: 98968
        keyvalue: 98968
    ]
    $scope.statuses = [
        keyvalue: 'Signed'
        keyname: 'Y'
      ,
        keyvalue: 'Unsigned'
        keyname: 'N'
    ]

    $scope.isCategorySelected = (id) ->
      return false if _.isUndefined($scope.searchObj.category)
      $scope.searchObj.category.find (category) ->
        category.name == id

    savedFilterKey = () ->
      "savedFilter_#{$scope.isTreatmentPlan}"

    $scope.filter = (exportPDF=false)->
      console.log @searchObj
      session.set savedFilterKey(), JSON.stringify(@searchObj)

      extractVals = (collection) ->
        return unless collection
        _.map collection, (item) -> item.name

      setParam = (params, field) ->
        params[field] = $scope.searchObj[field] if $scope.searchObj[field]

      setParamName = (params, field) ->
        params[field] = $scope.searchObj[field].name if $scope.searchObj[field]

      params =
        simple: true
        'patient_ids[]':  extractVals $scope.searchObj.patient
        'provider_ids[]': extractVals $scope.searchObj.provider
        'facility_ids[]': extractVals $scope.searchObj.facility
        'cpts[]':         extractVals $scope.searchObj.cpt_code
        'signed[]':       extractVals $scope.searchObj.signed
        'primary_insurance_id[]':    extractVals $scope.searchObj.primary_insurances
        'secondary_insurance_id[]':  extractVals $scope.searchObj.secondary_insurances

      params.from = $scope.searchObj.from if $scope.searchObj.from
      params.to = $scope.searchObj.to if $scope.searchObj.to

      params.signed_from = $scope.searchObj.signedFrom if $scope.searchObj.signedFrom
      params.signed_to = $scope.searchObj.signedTo if $scope.searchObj.signedTo

      if $scope.isTreatmentPlan
        params['cpts[]'] = ['TP']

      if $scope.isCategorySelected(1)
        params['background_history_mental_illnesses[]'] = extractVals $scope.searchObj.background_history_mental_illnesses

        setParamName(params, 'background_history_birth_place')
        setParamName(params, 'background_history_education_status')
        setParamName(params, 'background_history_family_background')
        setParamName(params, 'background_history_family_status')
        setParamName(params, 'background_history_marital_status')
        setParamName(params, 'background_history_occupational_status')
        setParamName(params, 'background_history_raised_by')
        setParamName(params, 'background_history_religious_status')

      if $scope.isCategorySelected(2)
        params['therapeutic_communication_attempted_tos[]'] = extractVals $scope.searchObj.therapeutic_communication_attempted_tos
        params['therapeutic_communication_modalities[]'] = extractVals $scope.searchObj.therapeutic_communication_modalities

      if $scope.isCategorySelected(3)
        setParamName(params, 'diagnosis_primary')
        setParamName(params, 'diagnosis_progosis')
        setParamName(params, 'diagnosis_secondary')

      if $scope.isCategorySelected(4)
        params['functional_status_interactive_complexities[]'] = extractVals $scope.searchObj.functional_status_interactive_complexities
        params['functional_status_severities[]'] = extractVals $scope.searchObj.functional_status_severities

      if $scope.isCategorySelected(5)
        params['group_data_interventions_therapeutic_factors[]'] = extractVals $scope.searchObj.group_data_interventions_therapeutic_factors

        setParamName(params, 'group_data_interventions_cgii')

      if $scope.isCategorySelected(6)
        params['plan_crisis_mobilizations[]'] = extractVals $scope.searchObj.plan_crisis_mobilizations

        setParamName(params, 'plan_crisis_psychotherapy')
        setParamName(params, 'plan_crisis_recommendation')
        setParamName(params, 'plan_crisis_risk_assessment')

      if $scope.isCategorySelected(7)
        params['problem_major_target_symptoms[]'] = extractVals $scope.searchObj.problem_major_target_symptoms

      if $scope.isCategorySelected(8)
        params['functional_status_severities[]'] = extractVals $scope.searchObj.functional_status_severities

        setParamName(params, 'functional_status_description')
        setParamName(params, 'functional_status_insight')
        setParamName(params, 'functional_status_intability')
        setParamName(params, 'functional_status_motivation')
        setParamName(params, 'functional_status_reasoning')
        setParamName(params, 'functional_status_recall')
        setParamName(params, 'functional_status_thought_process')

      if $scope.isCategorySelected(9)
        params['referral_initiators[]'] = extractVals $scope.searchObj.referral_initiators
        params['referral_reasons[]'] = extractVals $scope.searchObj.referral_reasons
        params['referral_medical_necessities[]'] = extractVals $scope.searchObj.referral_medical_necessities

        setParam(params, 'service_date_from')
        setParam(params, 'service_date_to')

        setParam(params, 'md_order_date_from')
        setParam(params, 'md_order_date_to')

        setParamName(params, 'referral_hiatus_reason')
        setParamName(params, 'referral_md_name')

      if $scope.isCategorySelected(10)
        params['problem_others[]'] = extractVals $scope.searchObj.problem_others
        params['problem_precipitating_stressors[]'] = extractVals $scope.searchObj.problem_precipitating_stressors

        setParamName(params, 'problem_frequency')
        setParamName(params, 'problem_intensity')
        setParamName(params, 'problem_onset')
        setParamName(params, 'problem_staff_impression')

      if $scope.isCategorySelected(11)
        params['progress_monitoring_mechanisms[]'] = extractVals $scope.searchObj.progress_monitoring_mechanisms

        setParamName(params, 'progress_session')
        setParamName(params, 'progress_cgii')
        setParamName(params, 'progress_frequency')

      if $scope.isCategorySelected(12)
        params['problem_major_target_symptoms[]'] = extractVals $scope.searchObj.problem_major_target_symptoms
        params['problem_others[]'] = extractVals $scope.searchObj.problem_others
        params['problem_tp_interventions[]'] = extractVals $scope.searchObj.problem_tp_interventions

        setParamName(params, 'problem_frequency')
        setParamName(params, 'problem_intensity')
        setParamName(params, 'problem_onset')

      if $scope.isCategorySelected(13)
        params['plan_other_services[]'] = extractVals $scope.searchObj.plan_other_services

        setParamName(params, 'plan_amount_of_service')
        setParamName(params, 'plan_duration')
        setParamName(params, 'plan_frequency')

      if $scope.isCategorySelected(14)
        params['tp_methods_methods[]'] = extractVals $scope.searchObj.tp_methods_methods

        setParamName(params, 'functional_status_severity')

      if $scope.isCategorySelected(15)
        setParam(params, 'certification_from')
        setParam(params, 'certification_to')

      if exportPDF
        window.location.href = $scope.exportURL + "&export_pdf=#{exportPDF}"
      else
        $scope.searchURL = "/api/encounters"
        $scope.global.search = params
        $scope.searchTransform = (result, headers) ->
          if _.has(result, 'data')
            $scope.exportURL = headers('x-export-url')
            $scope.initNavLists [result.meta.links] if result.data?.length 
            result.data || []
          else
            []

    if savedFilter = session.get savedFilterKey()
      $scope.searchObj = JSON.parse(savedFilter)
      $scope.filter()
    else
      $scope.searchObj = {}

    $scope.$watch 'searchObj.cpt_code', (val) ->
      $scope.setCategoriesFor(val)

    $scope.cpt_codes  = [
      keyname: 90791
      keyvalue: 90791
    ,
      keyname: 90832
      keyvalue: 90832
    ,
      keyname: 90834
      keyvalue: 90834
    ,
      keyname: 90837
      keyvalue: 90837
    ,
      keyname: 90839
      keyvalue: 90839
    ,
      keyname: 90853
      keyvalue: 90853
    ,
      keyname: 90846
      keyvalue: 90846
    ,
      keyname: 90847
      keyvalue: 90847
    ,
      keyname: 96116
      keyvalue: '961xx'
    ,
      keyname: 'TP'
      keyvalue: 'Treatment Plan'
    ,
      keyname: 98966
      keyvalue: 98966
    ,
      keyname: 98967
      keyvalue: 98967
    ,
      keyname: 98968
      keyvalue: 98968
    ]

    # available categories based on CPT code
    $scope.setCategoriesFor = (cptCodes)->
      return if !$scope.isTreatmentPlan && (!cptCodes || cptCodes.length != 1)
      cptCodes ||= []
      cptCode = cptCodes[0] && cptCodes[0].val
      return if !$scope.isTreatmentPlan && !cptCode

      categories = [
        { keyvalue: "Patient Information", keyname: 9 }
        { keyvalue: "Mental Status Examination", keyname: 8 }
        { keyvalue: "Background and History", keyname: 1 }
        { keyvalue: "Problem Description/Medical Necessity", keyname: 10 }
        { keyvalue: "Functional Status", keyname: 4 }
        { keyvalue: "Diagnosis and Prognosis", keyname: 3 }
        { keyvalue: "Major target symptom", keyname: 7 }
        { keyvalue: "Definitive Therapeutic Communication", keyname: 2 }
        { keyvalue: "Progress and Methods of Monitoring Outcomes", keyname: 11 }
        { keyvalue: "Interventions", keyname: 6 }
        { keyvalue: "Interventions and Progress", keyname: 5 }
        { keyvalue: "Target Symptoms and Treatment Plan Interventions", keyname: 12 }
        { keyvalue: "Initial Recommendations and Plan", keyname: 13 }
        { keyvalue: "Methods of Monitoring Outcomes", keyname: 14 }
        { keyvalue: "Certification of Goals", keyname: 15 }
      ]

      availableCategories = []
      if $scope.isTreatmentPlan
        availableCategories = [9, 3, 12, 13, 14, 15]
      else
        switch cptCode
          when 90791
            availableCategories = [1, 3, 8, 9, 10]
            break
          when 90839
            availableCategories = [1, 3, 6, 8, 9, 10]
          when 90853
            availableCategories = [1, 3, 5, 9]
          when 90832, 90834, 90837, 90846, 90847, 98966, 98967, 98968
            availableCategories = [2, 3, 4, 7, 9, 11]

      categories = categories.filter (category) ->
        availableCategories.includes(category.keyname)

      $scope.categories = categories

      # deselect unavailable categories
      if $scope.searchObj.category
        $scope.searchObj.category = $scope.searchObj.category.filter (selectedCategory) ->
          foundCategory = $scope.categories.filter (category) ->
            category.name == selectedCategory.name
          foundCategory.length > 0

    $scope.export = (ev)->
      $mdDialog.show
        controller: EncounterExportDialogController
        controllerAs: 'ctrl'
        templateUrl: "encounters/_encounters-export-dialog.html"
        parent: angular.element document.body
        targetEvent: ev
        clickOutsideToClose: true
        fullscreen: $mdMedia('sm') or $mdMedia('xs')
      .then((val) ->
        $scope.filter(val)
        console.log val
      , ->
        console.log 'dialog canceled'
      )

    encountersNavHelpers.sharedDefaults $scope

] #}}}

geripsy.controller "encounterController", [ #{{{
  '$scope'
  '$stateParams'
  '$state'
  '$sce'
  '$timeout'
  '$mdToast'
  '$http'
  'Encounter'
  'encounter'
  'Patient'
  'Provider'
  'Facility'
  'encounterHelpers'
  'abilities'
  'RefLookupService'
  'encountersNavHelpers'
  'EncounterFormSectionBuilderService'
  'EncounterValidations'
  'TestingService'
  ($scope, $stateParams, $state, $sce, $timeout, $mdToast, $http, Encounter, encounter, Patient, Provider, Facility, helpers, abilities, RefLookupService, encountersNavHelpers, EncFormBuilder, EncValidations, Testing) ->
    $scope.encresource = encounter
    $scope.myEncounter = encounter
    $scope.myPatient = helpers.patient()
    $scope.incidentToProviders = []
    # ensure facility_pos_code initialized
    $scope.myEncounter.facility_pos_code ?= $scope.myPatient.facility_pos_code

    $scope.showDate = ($state.current.name == 'encounter.editServiceDate')
    $scope.showTime = ($state.current.name == 'encounter.editServiceTime')

    objectify = (collection, key, val) ->
      _.map collection, (item) ->
        keyname: item[key]
        keyvalue: item[val]

    if !!$scope.myEncounter.incident_to_provider
      $scope.myEncounter.incident_to_provider = {
        name: $scope.myEncounter.incident_to_provider.id,
        value: $scope.myEncounter.incident_to_provider.full_name,
        degree: $scope.myEncounter.incident_to_provider.degree.name,
      }

    if $scope.myEncounter.cpt_encounter_code == '90791'
      Provider.get {id: $scope.user.meta.id, simple: true}, (provider)->
        $scope.incidentToProviders = objectify(provider.incident_to_providers, 'id', 'full_name')

    $scope.saveTimestamp = (enc) ->
      if $scope.showTime
        enc.certification.start_time = $("gd-time[field-name=start_time] input[type=time]").val()
        enc.certification.end_time = $("gd-time[field-name=end_time] input[type=time]").val()
      encounterParams = { certification: { start_time: enc.certification.start_time, end_time: enc.certification.end_time }, referral: { service_date: enc.referral.service_date } }
      href = $state.href('encountersApi.serviceTimestamp', {patient_id: enc.patient_id, id: enc.id})

      success = (response) ->
        $state.go($scope.sectionHome)

      error = (response) ->
        console.log response
        msgs = ["Encounter couldn't be saved:"]
        _.each response.data, (v,k) ->
          msgs.push [k, v[0]].join ": "
        $scope.Toast.display msgs

      $http.patch(href, encounter: encounterParams).then(success, error)

    $scope.testing =
      codes: Testing.codes
      services: Testing.srvcs
      impairments: Testing.impairments
      interferences: Testing.interferences
      headers: Testing.headers

    if formsec = formSecs[encounter.cpt_encounter_code]
      $scope.formsec = EncFormBuilder.buildForm $scope, formsec(),
        encPropName: 'myEncounter'

        validations: [
          (encounter) ->
            EncValidations.buildValidation(encounter, '90832', '98966', ->
              service_conducted = @encounter.therapeutic_communication?.service_conducted
              service = service_conducted?.name
              return @valid() if service is "7"
              return @invalid("Therapeutic communication - type was not selected") unless service

              timeDiff = @timeDiff()

              limits =
                switch service
                  when "1", "4" then [16, 37] #90832
                  when "2", "5" then [38, 52] #90834
                  when "3", "6" then [53]     #90837
                  when "8", "9" then [25]     #9084x
                  when "10"     then [5, 10]  #98966
                  when "11"     then [11, 20] #98967
                  when "12"     then [21, 30] #98968

              res =
                if limits.length is 2
                  timeDiff in [limits[0]..limits[1]]
                else
                  timeDiff > limits[0]

              if res
                @valid()
              else
                msg = "Service time of #{timeDiff} minutes is not a valid option for #{service_conducted?.val}. "
                if limits.length is 2
                  msg += "Length must be between #{limits.join('-')} mins"
                else
                  msg += "Length must be > #{limits[0]} mins"
                @invalid msg
            )
        ,

          (encounter) ->
            EncValidations.buildValidation(encounter, '90839', ->
              timeDiff = @timeDiff()
              return @valid() if timeDiff >= 53
              @invalid("Service time of #{timeDiff} minutes is not valid for this note. Must be 30 minutes or longer")
            )

        ,
          (encounter) ->
            EncValidations.buildValidation(encounter, '90791', ->
              if moment(@encounter.referral.order_date)
                .clone()
                .startOf('day')
                .isAfter(
                  moment(@encounter.referral.service_date).
                  clone().
                  startOf('day')
                )

                @invalid("MD Order must precede Service Date")
              else
                @valid()
            )
          ,
            (encounter) ->
              EncValidations.buildValidation(encounter, '96116', ->
                ref = @encounter.referral
                if ref.scoring_minutes > 0 or ref.tech_scoring_minutes > 0 or ref.computer_test_count > 0
                  @valid()
                else
                  @invalid("No scoring method was selected")
              )
        ]

        beforeSave: ->
          $scope.encresource.certify = true
          $scope.encresource.certification.sign_date = new Date
          $scope.encresource.provider_id = $scope.user.meta.id
          $scope.confirmDates().then  => $scope.confirmUntimed()

        submit: (opts={})->
          $scope.persist(opts).then (rs) ->
            if rs
              $scope.$broadcast 'reload-drs'

              # Need to make sure globalPatients.patients is
              # updated after signing
              #
              # Really mostly in case a patients has90791
              # value has changed
              $scope.$root.$broadcast 'populatePatientList'
              $state.go 'encounters'

      $scope.submit = -> $scope.formsec.submit(uncertify: true)

    $state.go 'encounters' if encounter.certified and !['encounter.print', 'encounter.editServiceDate', 'encounter.editServiceTime'].includes($state.current.name)

    $scope.isEditing = $state.current.data.isEditing

    # Quickfix for 908xx *therapeutic_communication*
    if encounter.cpt_encounter_code isnt '90839' && _.startsWith(encounter.cpt_encounter_code, '908')
      unless _.isPlainObject($scope.myEncounter.therapeutic_communication)
        $scope.myEncounter.therapeutic_communication = {}
      unless _.isPlainObject($scope.myEncounter.therapeutic_communication.service_conducted)
        $scope.myEncounter.therapeutic_communication.service_conducted = undefined

    if _.includes(['90791', '90839'], encounter.cpt_encounter_code)
      # default hiatus val
      unless _.isPlainObject $scope.myEncounter.referral
        $scope.myEncounter.referral = {}
      unless $scope.myEncounter.referral.hiatus
        $scope.myEncounter.referral.hiatus =
          val: 'No'
          name: 'N'

    # don't allow editing encs for inactives
    if $state.is 'encounter.edit'
      return if helpers.handleInactive $scope.myPatient

    $scope.getLookup = RefLookupService.getRefLookupLocal

    $scope.myEncounter.cpt_encounter_code = encounter.cpt_encounter_code
    $scope.state = $state
    $scope.currentId = $stateParams.id
    abilities.can('Enc::Encounter', ['update']).then (val) ->
      $scope.updateable = val

    $scope.titleBar = ->
      title = if $scope.isEditing then "Editing " else "Viewing "
      title += "Note #{encounter.cpt_encounter_code} for #{$scope.myPatient.fullName()}"

    if encounter.cpt_encounter_code is "TP" || encounter.cpt_encounter_code is "GBH1"
      $scope.myEncounter.certification ?= {}
      $scope.myEncounter.certification.treatment_plan_date ?= new Date
      $scope.myEncounter.referral ?= {}
      $scope.myEncounter.referral.service_date ?= new Date
      $scope.$watch 'myEncounter.goals', (newval) ->
        vals = _.values(newval)
        goals = $scope.formsec.sections.goals
        goals.valid = goals.hasInput = not _.isEmpty(_.compact(vals))
      ,
        true

      $scope.$watch 'myEncounter.certification', (newval) ->
        MINIMUM_TIME = 20 * 60 * 1000
        TIME_OFFSET = 31000

        startTime = newval.start_time && newval.start_time.getTime()
        endTime = newval.end_time && newval.end_time.getTime()
        timeDifference = null
        if startTime && endTime
          timeDifference = endTime - startTime + TIME_OFFSET

        certification = $scope.formsec.sections.certification
        certification.valid = certification.hasValidTime = (timeDifference && timeDifference >= MINIMUM_TIME)
        console.log certification.valid
      ,
        true

      $scope.formsec.showErrors()


    helpers.sharedDefaults $scope, $state, $timeout, Facility
    $scope.dateConverter.prepareEncDates $scope.myEncounter, !!$scope.encresource.signed_on

    $scope.edit = ->
      $state.go("encounter.edit", $stateParams).then ->
        $state.reload()

    $scope.$on 'patient-scope-changed', (event, id) ->
      $state.go 'encounters' unless id is $scope.myPatient.id

    $scope.setUpdateable 'Enc::Encounter'

    encountersNavHelpers.sharedDefaults $scope
    $scope.initNavHelpers() unless $scope.isEditing
] #}}}

geripsy.controller 'encountersCreateController', [ #{{{
  '$scope'
  '$stateParams'
  '$state'
  '$mdDialog'
  '$rootScope'
  '$timeout'
  '$q'
  '$mdToast'
  '$location'
  'SessionStorage'
  'Encounter'
  'encounter'
  'Patient'
  'Facility'
  'encounterHelpers'
  'RefLookupService'
  'treatment_plan'
  ($scope, $stateParams, $state, $mdDialog, $rootScope, $timeout, $q, $mdToast, $location, sessionStorage, Encounter, encounter, Patient, Facility, helpers, RefLookupService, treatment_plan) ->
    $scope.myPatient = helpers.patient()
    return if helpers.handleInactive $scope.myPatient

    $scope.titleBar = ->
      "Create New Encounter for #{$scope.myPatient.fullName()}"

    # find latest encounters, prepopulate as needed, and render dialog
    Encounter.query {patient_id: $scope.myPatient.id}, (encounters) ->
      encs = _.groupBy encounters, (e)-> e.cpt_encounter_code

      if encs.hasOwnProperty '90791'
        unsigned = _.find(encs['90791'], (e) -> not e.certified)
        signed = _.filter encs['90791'], 'certified'
        latest = _.maxBy signed, 'service_date'
        if latest
          msg = "Please choose the note type. This patient has an initial note already from #{moment(latest.service_date).format('ll')}"
      if encs.hasOwnProperty '90832'
        unsigned90832 = _.find(encs['90832'], (e) -> not e.certified)
      if encs.hasOwnProperty 'TP'
        unsignedTP = _.find(encs['TP'], (e) -> not e.certified)
      if encs.hasOwnProperty 'GBH1'
        unsignedGBH1 = _.find(encs['GBH1'], (e) -> not e.certified)
      if encs.hasOwnProperty '90839'
        unsigned90839 = _.find(encs['90839'], (e) -> not e.certified)
      if encs.hasOwnProperty '96116'
        unsigned96116 = _.find(encs['96116'], (e) -> not e.certified)
      if encs.hasOwnProperty '98966'
        unsigned98966 = _.find(encs['98966'], (e) -> not e.certified)

      hasLinkedProvider = !!$scope.user.meta.linked_provider_id
      if hasLinkedProvider
        templateUrl = 'encounters/_encounter-type-dialog-incident-to-tmpl.html'
        encTemplates = ["90834", "90832", "90837", "90846", "90847", "90875", "90853", "GBH1", "TP"]
      else
        templateUrl = 'encounters/_encounter-type-dialog-tmpl.html'
        encTemplates = ["90791", "90839", "90832", "90853", "TP", "GBH1", "96116", "98966"]
      $scope.encTemplates = encTemplates

      encTypeDiag =
        controller: ['$scope', '$mdDialog', ($scope, $mdDialog) ->
          $scope.close = ->
            $mdDialog.hide($scope.encounterType)
          $scope.msg = msg or "Please choose which note to create. This patient does not have a previous initial note"
        ]
        templateUrl: templateUrl
        parent: angular.element document.body
        clickOutsideToClose: false
        escapeToClose: false

      createNewOrGotoEdit = (type, existing) ->
        if existing
          $state.go "encounter.edit", id: existing.id
        else
          encounter.patient_id = $scope.myPatient.id
          encounter.cpt_encounter_code = type
          encounter.$save (enc) ->
            $state.go "encounter.edit", id: enc.id
          , $scope.onSubmitFailure

      doEncounter = (type) ->
        switch type
          when '90791' then createNewOrGotoEdit "90791", unsigned
          when '90832' then createNewOrGotoEdit "90832", unsigned90832
          when '90839' then createNewOrGotoEdit "90839", unsigned90839
          when 'TP' then createNewOrGotoEdit "TP", unsignedTP
          when 'GBH1' then createNewOrGotoEdit "GBH1", unsignedGBH1
          when '90853' then $state.go 'newGroupEncounter'
          when '96116' then createNewOrGotoEdit "96116", unsigned96116
          when '98966' then createNewOrGotoEdit "98966", unsigned98966

      query = $location.search()
      if _.includes(encTemplates, query.enc_type)
        doEncounter(query.enc_type)
      else
        doEncDiag = -> $mdDialog.show(encTypeDiag).then (enctype) ->
          if _.includes(encTemplates, enctype)
            doEncounter(enctype)
          else
            debugger
            $scope.Toast.display ["Something went wrong. Please try again"]
            $state.go 'encounters'


        if $scope.myPatient.needs_tp
          $mdDialog.show($mdDialog.confirm()
            .title "Missing Treatment Plan"
            .textContent "This patient requires a treatment plan. You can add a new treatment plan now or proceed with other encounters"
            .ok "Add Treatment Plan"
            .cancel "Cancel"
          ).then (-> doEncounter('TP')), doEncDiag
        else
          doEncDiag()
] #}}}

geripsy.controller 'encountersPrintController', [ #{{{
  '$scope'
  '$rootScope'
  '$state'
  '$stateParams'
  '$timeout'
  '$sce'
  '$mdDialog'
  '$mdMedia'
  '$http'
  'Encounter'
  'encounter'
  'Patient'
  'encounterHelpers'
  'TestingService'
  ($scope, $rootScope, $state, $stateParams, $timeout, $sce, $mdDialog, $mdMedia, $http, Encounter, encounter, Patient, helpers, TestNote) ->
    tmplts =
      90791:
        content: 'encounters/print/_90791-content.html'
        cert: 'encounters/print/_90791-cert.html'
      90839:
        content: 'encounters/print/_90791-content.html'
        cert: 'encounters/print/_90791-cert.html'
      90832:
        content: 'encounters/print/_90832-content.html'
        cert: 'encounters/print/_90791-cert.html'
      TP:
        content: 'encounters/print/_TP-content.html'
        cert: 'encounters/print/_TP-cert.html'
      GBH1:
        content: 'encounters/print/_GBH1-content.html'
        cert: 'encounters/print/_GBH1-cert.html'
      90853:
        content: 'encounters/print/_90853-content.html'
        cert: 'encounters/print/_90791-cert.html'
      96116:
        content: 'encounters/print/_96116-content.html'
        cert: 'encounters/print/_96116-cert.html'
      98966:
        content: 'encounters/print/_98966-content.html'
        cert: 'encounters/print/_90791-cert.html'

    # Kind of like the idea of moving to
    # pulling all logic/settings into
    # their own services
    noteType = (code) ->
      switch code
        when '96116' then TestNote
        else {}

    $scope.note = noteType(encounter.cpt_encounter_code)
    $scope.templates = tmplts[encounter.cpt_encounter_code]
    $scope.is90791 = encounter.cpt_encounter_code == '90791'
    $scope.patient = helpers.patient()
    $scope.encresource = encounter
    $scope.encounter = encounter
    $scope.encounterShipped = false
    $scope.totalMins = ( ()->
      try
        cert = encounter.certification
        now = moment()
        endTime = cert.end_time.split(":")
        startTime = cert.start_time.split(":")
        now.hours(endTime[0]).minutes(endTime[1]).diff(now.clone().hours(startTime[0]).minutes(startTime[1]), 'minutes')
      catch err
        console.error err
        0
    )()

    $scope.canViewConfidential =
      try
        $scope.user.user_type is "Usr::Admin" or
          ($scope.user.user_type is "Usr::Provider" and encounter.signer.id is $scope.user.meta.id)
      catch err
        console.error err
        false

    $scope.isAdmin =
      try
        $scope.user.user_type is "Usr::Admin"
      catch err
        console.error err
        false

    $scope.prepTime = (encounter) ->
      if encounter.certification.start_time && encounter.certification.end_time
        startTime = encounter.certification.start_time.split(':')
        endTime = encounter.certification.end_time.split(':')

        startTimeHours = parseInt(startTime[0])
        endTimeHours = parseInt(endTime[0])
        hoursDiff = endTimeHours - startTimeHours

        startTimeMinutes = parseInt(startTime[1])
        endTimeMinutes = parseInt(endTime[1])
        minutesDiff = endTimeMinutes - startTimeMinutes

        totalMinutesDiff = (hoursDiff * 60) + minutesDiff

        totalMinutesDiff + ' minutes'
      else
        ''

    $scope.frameSrc = $sce.trustAsResourceUrl "/encounters/#{$stateParams.id}/print_content"
    $scope.printNote = ->
      window.frames['printcontent'].focus()
      window.frames['printcontent'].print()

    exportEnc = (ev, format) ->
      $mdDialog.show
        controller: EncounterExportDialogController
        controllerAs: 'ctrl'
        templateUrl: "encounters/_encounters-export-dialog.html"
        parent: angular.element document.body
        targetEvent: ev
        clickOutsideToClose: true
        fullscreen: $mdMedia('sm') or $mdMedia('xs')
      .then((val) ->
        location.href = "/api/patients/#{$scope.patient.id}/encounters/#{encounter.id}.#{format}?type=#{val}"
      , ->
        console.log 'dialog canceled'
      )
    $scope.exportPDF = (ev)->
      exportEnc ev, 'pdf'
      #location.href = "/api/patients/#{$scope.patient.id}/encounters/#{encounter.id}.pdf"
    $scope.exportDOC = (ev)->
      exportEnc ev, 'docx'
      #location.href = "/api/patients/#{$scope.patient.id}/encounters/#{encounter.id}.docx"
    $scope.shipClaimMd = (ev)->
      message = "Are you sure you want to ship this encounter to ClaimMD?"
      result = confirm(message)
      if result == true
        $scope.encounterShipped = true
        $http.patch($state.href('encountersApi.shipClaimMd', {patient_id: $scope.patient.id, id: encounter.id}))

    if _.includes(['90791', '90839'], encounter.cpt_encounter_code)
      initialCode =
        if encounter.cpt_encounter_code is '90839'
          code = '90839'
          code += ',90840' if encounter.has_90840
          code
        else if $scope.encresource.has_interactive_complexity
          "90791,90785"
        else
          "90791"
      $scope.initialHeader =
        if encounter.cpt_encounter_code is '90839'
          console.log initialCode
          hdr = "Psychotherapy in Crisis (#{initialCode}"
          if !!$scope.user.meta.linked_provider_id
            hdr += '-"Incident to"'
          hdr += ")"
          hdr
        else
          hdr = "PSYCHOLOGY INITIAL EVALUATION (#{initialCode})"
          hdr += " [UNBILLED]" if $scope.encresource.unbilled
          hdr

    if encounter.cpt_encounter_code is '90853'
      hdr = "90853"
      if !!$scope.user.meta.linked_provider_id
        hdr += '-"Incident to"'
      hdr += " Group Psychotherapy"
      hdr += " [UNBILLED]" if $scope.encresource.unbilled
      $scope.groupHeader = hdr

    $rootScope.printView = $state.current.name is 'encountersPrintContent'
    $scope.hiatusFormat = (reason) ->
      return '' unless reason.name
      text = $scope.format(reason)
      if reason.name is 'hospitalized' or reason.name is 'transferred'
        date =
          if d = $scope.encounter.referral.hiatus_date
            momentu(d).format "L"
          else
            'date unknown'

        [text, date].join ' '
      else
        text

    $scope.format = (val, extraProp, hasRootLabel=false) ->
      if angular.isArray(val)
        _.map(val, (e) -> e.freetext or e.val).join '; '
      else if extraProp and angular.isArray(val[extraProp])
        if hasRootLabel
          [val.val, $scope.format val[extraProp]].join ' - '
        else
          $scope.format val[extraProp]
      else if val?.name is 'FREETEXT'
        val.freetext
      else
        val?.val or val?.name or val

    $scope.formatProb = (val, prop, name, hasRootLabel=false) ->
      if val.name == name
        $scope.format(val, prop, hasRootLabel)
      else
        val.val

    $scope.formatTestingBgSrv = (field, opts={}) ->
      srv = encounter.background_history[field]
      extra = encounter.background_history.extra or {}
      xxx = if srv is "Yes" and extra[field]
        "YES: " + extra[field]
      else if opts.no and srv is "No"
        opts.no
      else if opts.extraNo and srv is "No" and extra[field]
        "NO: " + extra[field]
      else
        _.upperCase srv

      console.log xxx, field, opts, srv
      xxx


    # NOTE think there's a bug in $scope.format
    # since we are not currently handling cases where
    # extraProp is sent but val[extraProp] is Object not Array
    #
    # Pulling this out for individual cases for now until
    # I have time to look at it in depth. (which is never)
    $scope.formatIntComp = (val, probs) ->
      [val.val, $scope.format(val[probs])].join ' - '

    if reasons = encounter.referral?.reasons
      $scope.hasPlan = !!_.find reasons, (reason) -> reason.name is "1"
      $scope.hasCompetency = !!_.find reasons, (reason) -> reason.name is "2"

    $scope.setUpdateable 'Enc::Encounter'

    if encounter.cpt_encounter_code is "TP"
      $scope.monitoringMethods = encounter.tp_methods.methods
      if other = _.find($scope.monitoringMethods, (meth) -> meth.name is "diffscale")
        other.val = encounter.tp_methods.diffscale['name']

    # ADDENDUM
    $scope.addendum =
      text: ''
    $scope.submitAddendum = ->
      return false unless $scope.addendum?.text.length
      reqPatId = $scope.globalPatients.currentEncReqPatientId
      sesPatId = $scope.globalPatients.currentPatient.id
      scopePat = reqPatId and reqPatId isnt sesPatId
      revertPat = ()-> $scope.globalPatients.setPatient(sesPatId, false) if scopePat

      $scope.globalPatients.setPatient(reqPatId, false) if scopePat

      Encounter.update({patient_id: $scope.patient.id, id: $stateParams.id}, { encounter: {addendum: $scope.addendum.text, addendum_user_id: $scope.user.id} }, ->
        $scope.Toast.display ["Addendum added successfully"]
        $state.reload().then revertPat
      ,
        ->
          $scope.Toast.display ["Error: Could not save addendum"]
          revertPat()
      )
] #}}}
