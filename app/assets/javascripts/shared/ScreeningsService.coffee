geripsy.factory 'ScreeningsService', ->
  screenings =
    bcrs: [
      {
        name: "I. Concentration"
        labels: [
          "1 - No objective or subjective evidence of deficit in concentration."
          "2 - Subjective decrement in concentration ability."
          "3 - Minor objective signs of poor concentration (e.g., subtraction of serial 7's from 100)."
          "4 - Definite concentration deficit for persons of their backgrounds (e.g. marked deficit on serial 7's; frequent deficit in subtraction of serials 4's from 40)."
          "5 - Marked concentration deficit (e.g., giving months backwards or serials 2's from 20)."
          "6 - Forgets the concentration task. Frequently begins to count forward when asked to count backwards from 10 by 1's."
          "7 - Marked difficulty counting forward to 10 by 1's."
        ]
      },

      {
        name: "II. Recent Memory"
        labels: [
          "1 - No objective or subjective evidence of deficit in recent memory."
          "2 - Subjective impairment only (e.g., forgetting names more than formerly)."
          "3 - Deficit in recall of specific events evident upon detailed questioning. No deficit in recall of major recent events."
          "4 - Cannot recall major events of previous weekend or week. Scanty knowledge (not detailed) of current events, favorite TV shows, etc."
          "5 - Unsure of weather; may not know current President or current address."
          "6 - Occasional knowledge of some events. Little or no idea of current address, weather, etc."
          "7 - No knowledge of any recent events."
        ]
      },

      {
        name: "III. Past Memory"
        labels: [
          "1 - No subjective or objective impairment in past memory."
          "2 - Subjective impairment only. Can recall two or more primary school teachers."
          "3 - Some gaps in past memory upon detailed questioning. Able to recall at least one childhood teacher and/or one childhood friend."
          "4 - Clear-cut deficit. The spouse recalls more of the patient's past than the patient. Cannot recall childhood friends and/or teachers but knows the names of most schools attended. Confuses chronology in reciting personal history."
          "5 - Major past events sometimes not recalled (e.g., names of schools attended)."
          "6 - Some residual memory of past (e.g., may recall country of birth or former occupation)."
          "7 - No memory of past."
        ]
      },

      {
        name: "IV. Orientation"
        labels: [
          "1 - No deficit in memory for time, place, identify of self or others."
          "2 - Subjective impairment only. Knows time to nearest hour, location."
          "3 - Any mistakes in time >2 hours: day of week > 1 day; date > 3 days."
          "4 - Mistakes in month > 10 days or year > 1 month."
          "5 - Unsure of month and/or year and/or season; unsure of locale."
          "6 - No idea of date. Identifies spouse but may not recall name. Knows own name."
          "7 - Cannot identify spouse. May be unsure of personal identity."
        ]
      },

      {
        summary: true
        name: "BCRS Summary Score"
        labels: [
          "1 - No cognitive decline"
          "2 - Very mild cognitive decline (Age Associated Memory Impairment)"
          "3 - Mild cognitive decline (Mild Cognitive Impairment)"
          "4 - Moderate cognitive decline (Mild Dementia)"
          "5 - Moderately severe cognitive decline (Moderate Dementia)"
          "6 - Severe cognitive decline (Moderately Severe  Dementia)"
          "7 - Very severe cognitive decline (Severe Dementia)"
        ]

      }
    ]

