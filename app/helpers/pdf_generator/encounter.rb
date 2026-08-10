module PdfGenerator
  class Encounter < Base
    define_generator '90791', '90839' do #{{{
      is90791 = encounter.cpt_encounter_code == '90791'
      if !is90791
        cptcode = "90839"
        cptcode << ",90840" if encounter.has_90840?
        header "Psychotherapy in Crisis (#{cptcode})"
      else
        cptcode = "90791"
        cptcode << ",90785" if encounter.has_interactive_complexity?
        header "PSYCHOLOGY INITIAL EVALUATION (#{cptcode})"
      end

      section "I. Patient Information" do #{{{
        make_table [
          [
            cell("Last Name", patient.last_name),
            cell("First Name", patient.first_name),
            cell("DOB", date(patient.dob))
          ],
          [
            cell("Facility", patient.facility_room),
            cell("Gender", patient.gender),
            cell("Referral initiated by", format(encounter.referral.initiator, 'REFINITIATOR'))
          ],
          [
            cell("Referring MD name", -> {patient.facility.doctors.find(encounter.referral.md_name.name).try(:name) }),
            cell("Date of MD order", date(encounter.referral.order_date))
          ]
        ]

        if is90791
          hiatus = encounter.referral.hiatus
          if hiatus.try(:name) == 'Y' && (reason = encounter.referral.hiatus_reason).try(:name)
            hdr = "Patient was seen in the last year for a 90791. A hiatus in treatment has taken place due to"
            text = format(reason, 'HAS90791THISYEAR')
            val =
              if reason.name.in?(%w(hospitalized transferred))
                _date =
                  if hdate = encounter.referral.hiatus_date
                    date(hdate)
                  else
                    'date unknown'
                  end
                [text, _date] * ' '
              else
                text
              end
            make_table [[cell(hdr, val)]]

            if encounter.referral.hiatus_comment.present?
              make_table [[ cell("Comment", encounter.referral.hiatus_comment) ]]
            end
          end
          make_table [
            [
              cell("Reason for referral", format(encounter.referral.reasons, "REFREASONS"))
            ],
            [
              cell("Medical necessity", format(encounter.referral.medical_necessity, "MEDICALNECESSITY"))
            ]
          ]
        end
      end #}}}

      section "II. Mental Status Examination", if: -> {encounter.functional_status} do #{{{
        fs = encounter.functional_status
        make_table [
          [
            cell("Clinical Global Impression-Severity", format(fs.severity, 'CGIS'))
          ]
        ]

        make_table [
          [
            cell("Orientation Problems", format(fs.orientation, 'ORIENTATION', if: ->(v){ v.name == 'P' })),
            cell("Appearance and Dress", format(fs.appearance, 'DRESS', if: ->(v){ v.name == 'I' })),
          ],
          [
            cell("Motor Activity", format(fs.motor, 'MOTOR', if: ->(v){ v.name == 'R' })),
            cell("Alertness/Concentration", format(fs.alertness, 'ALERTNESS'))
          ],
          [
            cell("Mood", format(fs.mood, 'MOOD', if: ->(v){ v.name == 'A' })),
            cell("Affect", format(fs.affect, 'AFFECT', if: ->(v){ v.name == 'B' }))
          ],
          [
            cell("Communication/Expression", format(fs.expression, 'EXPRESSION', if: ->(v){ v.name == 'B' })),
            cell("Behavioral Style/Attitude", format(fs.attitude, 'ATTITUDE', if: ->(v){ v.name == 'B' }))
          ],
          [
            cell("Judgment/Reasoning", format(fs.reasoning, 'REASONING')),
            cell("Motivation", format(fs.motivation, 'MOTIVATION'))
          ],
        ]

        make_table [[cell("Thought Process", format(fs.thought_process, 'THOUGHTPR'))]]

        th_content = fs.thought_content
        content_cell = if th_content.name != 'A'
          cell("Thought content/preoccupations", format(th_content, 'THOUGHTCONT'))
        else
          content = format(th_content, 'THOUGHTCONT') + " - "
          content += %i(obsessions compulsions phobias hypochondriasis other).map {|label|
            if cont = th_content.send(label)
              [label, cont].join ": "
            end
          }.compact.join '; '

          cell("Thought content/preoccupations", content)
        end

        make_table [[content_cell]]
        make_table [[cell("Memory/Recall", format(fs.recall, "RECALL"))]]
        make_table [
          [
            cell("Intellectual ability", format(fs.intellectual_ability, "INTABILITY")),
            cell("Insight/Awareness of problem", format(fs.insight, "INSIGHT"))
          ]
        ]

        harm = fs.harm
        harm_label = "Expressed threat of harm to self or others"
        if harm.name == 'Y'
          make_table [[cell(harm_label, format(harm.problems, 'EXPRHARM'))]]
        else
          make_table [[cell(harm_label, "No")]]
        end

        make_table [
          [
            cell("Cognitive screen", format(fs.respondtreatment, 'RESPONDTREATMNT'), fs.cognitive_screen, format(fs.respondtreatment_desc, 'RESPNDTREATMNTDESC'))
          ]
        ]

        if fs.note
          make_table [[cell("Note", fs.note)]]
        end

        if is90791 && fs.interactive_complexity.try(:name) == 'Y'
          make_table [[cell("Interactive complexity", format(fs.interactive_complexity.problems, 'REASONINTEACTVCOMPLXTY') )]]
        end
      end #}}}

      section "III. Background and History", if: ->{encounter.background_history} do #{{{
        bg = encounter.background_history
        table_data = [
          [
            cell("Family Status", [format(bg.marital_status, "MARITALSTATUS"), format(bg.family_status, "FAMILYSTATUS")].join('; ')),
            cell("Educational background", format(bg.education_status, "EDUSTATUS"))
          ],

          [
            cell("Social/Occupational background", format(bg.occupational_status, 'OCCUPATION')),
            cell("Place of birth", format(bg.birth_place, 'BIRTHPLACE'))
          ],

          [
            cell("Family Background", format(bg.family_background, 'FAMILYBACKGRND')),
            cell("Raised by", format(bg.raised_by, 'RAISEDBY'))
          ]
        ]

        mental_illness = [cell("History of mental illness", format(bg.hist_mental_ill, 'HISTMETNALILL'))]
        mental_illness << cell("Mental illness comment", bg.history_comment) if bg.history_comment

        table_data << mental_illness

        table_data << [
          cell("Religious/Spiritual status", format(bg.religious_status, 'RELIGIOUSSTATUS'))
        ]
        meds = bg.onpsychmeds
        meds_content = format(meds, 'ONMEDS')
        if meds.name == 'Y'
          meds_content += '; ' + bg.onpsychmeds_medication.to_s
        end
        table_data.last << cell("Psychiatric medication", meds_content)

        make_table table_data

        if meds.name == 'Y' && (gdr_opt=bg.gdr_plan)
          gdr_content = format(bg.gdr_plan, "GDRPLAN")
          if gdr_opt.name == 'Y'
            gdr_content << " - #{date(bg.gdr_plan_date)}"
          end
          make_table [[cell("GDR plan in place", gdr_content)]]
        end

        make_table [[cell("Relevant Medical Condition(s)", bg.medical_conditions)]]

        if bg.note
          make_table [[cell("Comments", bg.note)]]
        end
      end #}}}

      section 'IV. Problem Description', if: ->{encounter.problem} do #{{{
        pr = encounter.problem
        if is90791
          if pr
            make_table [
              [
                cell("Problem onset", format(pr.onset, 'PROBLEMONSET')),
                cell('Problem frequency/intensity', [format(pr.frequency, 'PROBLEMFREQ'), format(pr.intensity, 'PROBLEMINTENSITY')].join('; '))
              ]
            ]

            make_table [[cell('Other reported problems', format(pr.other, 'PROBLEMSOTHER'))]]
            make_table [[cell('Staff impression', format(pr.staffimpression, 'STAFFIMPRESSION'))]]
            make_table [[cell('Precipitating stressors', format(pr.precipstressors, 'PRECIPSTRESSORS'))]]
            make_table [[cell('Observations and background summary', pr.observation)]]
          end
        else #90839
          make_table [[ cell('Problem intensity', format(pr.intensity, 'PROBLEMINTENSITY') ) ]]
          make_table [[cell('Crisis state due to', format(pr.crisis_state, 'CRISISSTATES'))]]
          make_table [[cell('This issue presented itself', format(pr.crisis_history, 'CRISISHIST'))]]
          make_table [[cell('Personal reaction of the patient', format(pr.crisis_distress, 'CRISISDISTRESS'))]]
          if pr.crisis_comment
            make_table [[cell('Comments', pr.crisis_comment)]]
          end
        end
      end #}}}

      section 'V. Diagnosis and Prognosis', if: ->{encounter.diagnosis} do #{{{
        diag = encounter.diagnosis
        primary = Ref::Icd.where(icd: diag.primary.name).first
        data = [cell("Primary Diagnosis", primary.to_s)]
        if((secname=diag.secondary.try(:name)) && (ref=Ref::Icd.where(icd: secname).first))
          data << cell("Secondary Diagnosis", ref)
        end
        data << cell("Prognosis", format(diag.prognosis, 'PROGNOSIS'))
        make_table [data]

        if diag.comment
          make_table [[cell("General goals (subject to treatment plan)", diag.comment)]]
        end
      end #}}}

      if encounter.cpt_encounter_code == '90791'
        refreasons = encounter.referral.try(:reasons)
        if refreasons && refreasons.find {|reason| reason.name == "1"} # has initial plan
          section "VI. Initial Recommendations and Plan", if: ->{encounter.plan} do #{{{
            pl = encounter.plan
            make_table [[cell("Type/amount of psychotherapy service recommended", format(pl.amount_of_service, 'PLANRECOMMENDED'))]]
            if pl.amount_of_service.name == '4'
              make_table [[cell("Reason psychotherapy not recommended", format(pl.not_recommended_reason, 'PLANNOTRECOMMENDED'))]]
            else
              make_table [
                [
                  cell("Frequency", format(pl.frequency, 'PLANFREQUENCY')),
                  cell('Duration', format(pl.duration, 'PLANDURATION'))
                ]
              ]
              if pl.other_services
                make_table [[cell("Other services recommended", format(pl.other_services, 'PLANOTHERSERVICES'))]]
              end
            end
          end #}}}
        end

        if refreasons && refreasons.find {|reason| reason.name == "2"} # has competency findings
          section "VIb. Competency Findings", if: ->{encounter.competency} do #{{{
            comp = encounter.competency
            make_table [[cell("Findings", format(comp.findings, 'COMPETENCYFINDINGS'))]]
            if comp.comment
              make_table [[cell("Comments", comp.comment)]]
            end
          end #}}}
        end
      else #90839
        section "VI. Interventions", if: ->{encounter.plan} do #{{{
          pl = encounter.plan
          cells = [ cell("Pyschotherapy", format(pl.crisis_psychotherapy, "CRISISPSYCH"))]
          cells << cell("Comments", pl.crisis_psychotherapy_comment) if pl.crisis_psychotherapy_comment
          make_table [ cells ]

          cells = [ cell("Mobilization of resources to defuse crisis and restore safety", format(pl.crisis_mobilization, "CRISISMOBILIZATION")) ]
          cells << cell("Comments", pl.crisis_mobilization_comment) if pl.crisis_mobilization_comment
          make_table [ cells ]

          make_table [[ cell("Intervention summary", pl.crisis_intervention_summary) ]]

          cells = [ cell("Assessment of suicide/homicide risk", format(pl.crisis_risk_assessment, "CRISISRISK")) ]
          cells << cell("Comments", pl.crisis_risk_assessment_comment) if pl.crisis_risk_assessment_comment
          make_table [ cells ]

          rec = format(pl.crisis_recommendations, 'CRISISRECS')
          if pl.crisis_recommendations.try(:name) == '1'
            rec = [rec, pl.crisis_recommendation_until] * " "
          end
          make_table [[ cell("Recommendations", rec) ]]

          if pl.crisis_additional_time.try(:name) == 'Y'
            make_table [[ cell("Additional time required", format(pl.crisis_additional_time_minutes, 'CRISISTIME')) ]]
          end
        end #}}}
      end

      pdf.move_down 8

      encounter.cert_phrasings.each do |cert|
        pdf.text cert, size: 5
      end

      footer
    end #}}}

    define_generator '90832', '98966' do #{{{
      is98966 = encounter.cpt_encounter_code == '98966'

      header encounter.follow_up_header

      section 'I. Patient Information' do #{{{
        make_table [
          [
            cell("Last Name", patient.last_name),
            cell("First Name", patient.first_name),
            cell("DOB", date(patient.dob))
          ],
          [
            cell("Facility", patient.facility_room),
            cell("Gender", patient.gender)
          ]
        ]
      end #}}}

      section 'II. Functional Status', if: ->{encounter.functional_status} do #{{{
        fs = encounter.functional_status
        table_data = [
          [cell("Clinical Global Impression-Severity", format(fs.severity, 'CGIS'))],
          [cell("Behavioral Style/Attitude", format(fs.attitude, 'ATTITUDE', if: ->(v){ v.name == 'B' }))],
        ]
        harm = fs.harm
        harm_label = "Expressed threat of harm to self or others"
        if harm.name == 'Y'
          table_data << [cell(harm_label, format(harm.problems, 'EXPRHARM'))]
        else
          table_data << [cell(harm_label, "No")]
        end

        status = fs.status_changed
        status_label = "Observed or suspected change in mental status since last assessment"
        if status.name == 'Y'
          table_data << [cell(status_label, "Yes - #{status.freetext}")]
        else
          table_data << [cell(status_label, 'No')]
        end

        table_data << [cell("Cognitive screen", format(fs.respondtreatment, 'RESPONDTREATMNT'), fs.cognitive_screen, format(fs.respondtreatment_desc, 'RESPNDTREATMNTDESC'))]

        if fs.interactive_complexity.try(:name) == 'Y'
          table_data << [cell("Interactive complexity", format(fs.interactive_complexity.problems, 'REASONINTEACTVCOMPLXTY'))]
        end

        make_table table_data
      end #}}}

      section 'III. Background and History', if: -> { encounter.background_history } do #{{{
        bg = encounter.background_history
        change_content = -> (field) do
          val = bg.send(field)
          if val.name == 'Y'
            ['Yes', val.freetext].join(' - ')
          else
            'No'
          end
        end

        table_data = []
        table_data << [cell("Change in background/history", change_content[:status_changed])]
        table_data << [cell("Change in psychiatric medication", change_content[:meds_changed])]

        if 'Y'.in?([bg.onpsychmeds.try(:name), bg.meds_changed.name]) && (gdr_opt=bg.gdr_plan)
          gdr_content = format(bg.gdr_plan, "GDRPLAN")
          if gdr_opt.name == 'Y'
            gdr_content << " - #{date(bg.gdr_plan_date)}"
          end
          gdr_content << " --- see treatment plan for behavioral interventions"
          table_data << [cell("GDR plan in place", gdr_content)]
        end

        table_data << [cell("Change in relevant medical conditions", change_content[:condition_changed])]
        table_data << [cell("Observations and background summary", encounter.background_history.note)]

        make_table table_data
      end #}}}

      section 'IV. Diagnosis and Prognosis', if: ->{encounter.diagnosis} do #{{{
        diag = encounter.diagnosis
        primary = Ref::Icd.where(icd: diag.primary.name).first
        data = [cell("Primary Diagnosis", primary.to_s)]
        if((secname=diag.secondary.try(:name)) && (ref=Ref::Icd.where(icd: secname).first))
          data << cell("Secondary Diagnosis", ref)
        end
        make_table [data]

        make_table [
          [cell("General goals", diag.general_goals)],
          [cell("Goals for this session", diag.session_goals)],
          [cell("Prognosis", format(diag.prognosis, 'PROGNOSIS'))]
        ]
      end #}}}

      section 'V. Target Symptoms', if: -> {encounter.problem} do #{{{
        pr = encounter.problem
        make_table [[cell("Major target symptom", format(pr.major_target_symptom, 'MAJORTARGETSYM'))]]
        make_table [
          [
            cell("Problem onset", format(pr.onset, 'PROBLEMONSET')),
            cell("Problem frequency/intensity", [format(pr.frequency, 'PROBLEMFREQ'), format(pr.intensity, 'PROBLEMINTENSITY')].join('; '))
          ]
        ]
        make_table [[cell("Other reported problems", format(pr.other, 'PROBLEMSOTHER'))]]
      end #}}}

      section 'VI. Definitive Therapeutic Communication', if: ->{encounter.therapeutic_communication} do #{{{
        tc = encounter.therapeutic_communication

        make_table [[cell('Type/amount of psychotherapy service recommended', format(tc.service_conducted, 'SERVICECONDUCTED'))]]

        table_data = []
        if tc.service_conducted.try(:name).in?(%w(8 9)) # family therapy
          table_data << [cell("Therapeutic focus on", format(tc.therapeutic_focus, 'THERAPYFOCUS'))]
          if tc.therapeutic_comments
            table_data << [cell("Comments", [tc.therapeutic_comments.try(:maladaptive), tc.therapeutic_comments.try(:assist)].join('; '))]
          end
        else
          table_data << [cell("Modalities used", format(tc.modalities, 'MODALITIES'))]
          table_data << [cell("Therapy attempted to", format(tc.therapy_attempted_to, 'THERAPYATTEMPT'))]
        end

        if tc.family_present.try(:name) == 'Y'
          table_data << [cell('Family member present', [tc.family_present.try(:member_name), tc.family_present.try(:member_relationship)].join('; '))]
        end
        make_table table_data
      end #}}}

      section 'VII. Progress and Methods of Monitoring Outcomes', if: ->{encounter.progress} do #{{{
        pr = encounter.progress
        make_table [
          [cell('Progress this session', format(pr.session, 'SESSIONPROG'))],
          [cell('Monitoring mechanism(s)', format(pr.monitoring_mechanisms, 'MONITORMECH'))],
          [cell('Symptom severity level', pr.severity, pr.severity_comments)]
        ]
        if is98966
          make_table [[cell('Reason for patient initiated communication', pr.reason)]]
        else
          make_table [[cell('Progress to date', format(pr.cgii, 'CGII'))]]
          make_table [
            [
              cell('Frequency of treatment', format(pr.frequency, 'PLANFREQUENCY')),
              cell('Estimated duration of treatment', format(pr.duration, 'PROGDURATION'))
            ]
          ]
        end

        if !encounter.family_therapy?
          make_table [[cell("Therapy and progress notes", pr.notes)]]
        else
          data = [
            [cell('Therapy attempted to', format(pr.family_notes, 'FAMTHERAPYATTEMPT'))]
          ]

          unless omit_note?
            data << [cell('Comments', pr.family_notes_comments.try(:observe), pr.family_notes_comments.try(:assess))]
          end
          make_table data
        end

        make_table [[cell('Confidential notes regarding patient', pr.symptom_notes)]] if pr.symptom_notes && !omit_note?
      end #}}}

      pdf.move_down 8
      pdf.text Enc::Encounter::CERTS[:long], size: 5

      footer

    end # /90832 }}}

    define_generator 'TP' do #{{{
      header 'PSYCHOLOGY TREATMENT PLAN'

      section "I. Patient Information" do #{{{
        make_table [
          [
            cell("Last Name", patient.last_name),
            cell("First Name", patient.first_name),
            cell("DOB", date(patient.dob))
          ],
          [
            cell("Facility", patient.facility_room),
            cell("Gender", patient.gender),
            cell("Referral initiated by", format(encounter.referral.initiator, 'REFINITIATOR'))
          ],
          [
            cell("Referring MD name", patient.facility.doctors.find(encounter.referral.md_name.name).try(:name)),
            cell("Date of MD order", date(encounter.referral.order_date))
          ]
        ]

        tp_type = 'TPTYPE'

        plan_reasons = [cell("This is", format(encounter.referral.plan_type, tp_type))]
        if encounter.referral.plan_type.try(:name) == 'discharge'
          plan_reasons << cell("Reason for discharge", format(encounter.referral.discharge_reason, "TPDISREASONS"))
        end

        make_table [
          [
            cell("Reason for referral", format(encounter.referral.reasons, "REFREASONS"))
          ],
          plan_reasons
        ]
      end #}}}

      section 'II. Diagnosis and Prognosis', if: ->{encounter.diagnosis && encounter.functional_status} do #{{{
        diag = encounter.diagnosis
        primary = Ref::Icd.where(icd: diag.primary.name).first
        data = [cell("Primary Diagnosis", primary.to_s)]
        if((secname=diag.secondary.try(:name)) && (ref=Ref::Icd.where(icd: secname).first))
          data << cell("Secondary Diagnosis", ref)
        end
        make_table [data]
        make_table [
          [cell("Prognosis", format(diag.prognosis, 'PROGNOSIS'))],
          [cell("Relevant Medical Diagnosis/Condition", diag.medical_conditions)]
        ]

        pdf.move_down 8
        pdf.text "I certify that the patient’s cognitive status is appropriate for psychotherapy", size: 7

        make_table [
          [
            cell("Cognitive screen", format(encounter.functional_status.respondtreatment, 'RESPONDTREATMNT')),
            cell("Score", encounter.functional_status.cognitive_screen, format(encounter.functional_status.respondtreatment_desc, 'RESPNDTREATMNTDESC')),
            cell("Memory/Recall", format(encounter.functional_status.recall, "RECALL"))
          ]
        ]

        if tr_com = encounter.functional_status.respondtreatment_comments
          make_table [[cell("Comments", tr_com)]]
        end
      end #}}}

      section 'III. Target Symptoms and Treatment Plan Interventions', if: ->{encounter.problem && encounter.background_history} do #{{{
        pr = encounter.problem
        bg = encounter.background_history

        tp_interventions = 'TPINTERVENTIONS'

        make_table [
          [cell("Major target symptom", format(pr.major_target_symptom, 'MAJORTARGETSYM'))],
          [cell("Problem onset", format(pr.onset, 'PROBLEMONSET'))],
          [cell("Problem frequency/intensity", format(pr.frequency, 'PROBLEMFREQ'), format(pr.intensity, 'PROBLEMINTENSITY'))],
          [cell("Other reported problems", format(pr.other, 'PROBLEMSOTHER'))],
          [cell("Treatment plan interventions", format(pr.tp_interventions, tp_interventions))]
        ]

        meds_cells = []
        meds = bg.onpsychmeds
        meds_content = format(meds, 'ONMEDS')
        if meds.name == 'Y'
          meds_content += '; ' + bg.onpsychmeds_medication.to_s
        end
        meds_cells << cell("Psychiatric medication", meds_content)

        if meds.name == 'Y' && (gdr_opt = bg.gdr_plan)
          gdr_content = format(bg.gdr_plan, "GDRPLAN")
          if gdr_opt.name == 'Y'
            gdr_content << " - #{date(bg.gdr_plan_date)}"
          end
          meds_cells << cell("GDR plan in place", gdr_content)
        end
        make_table [meds_cells]

        if meds.name == 'Y' && bg.gdr_plan.try(:name).in?(['Y', 'YND'])
          make_table [[cell("Behavioral interventions expected to target following symptoms related to GDR", bg.gdr_plan_interventions)]]
        end

        if pr.comments_re_goals
          make_table [[cell("Comments re symptoms/interventions", pr.comments_re_goals)]]
        end
      end #}}}

      section 'IV. Initial Recommendations and Plan', if: ->{encounter.plan} do #{{{
        pl = encounter.plan
        make_table [[cell("Type/amount of psychotherapy service recommended", format(pl.amount_of_service, 'PLANRECOMMENDED'))]]
        if pl.amount_of_service.name == '4'
          make_table [[cell("Reason psychotherapy not recommended", format(pl.not_recommended_reason, 'PLANNOTRECOMMENDED'))]]
        else
          make_table [
            [
              cell("Frequency", format(pl.frequency, 'PLANFREQUENCY')),
              cell('Duration', format(pl.duration, 'PLANDURATION'))
            ]
          ]
          if pl.other_services
            make_table [[cell("Other services recommended", format(pl.other_services, 'PLANOTHERSERVICES'))]]
          end
        end
      end #}}}

      section 'V. Goals of Treatment', if: -> {encounter.goals} do #{{{
        if encounter.goals
          {
            increase: "INCREASE the frequency of",
            decrease: "DECREASE the frequency of",
            modify: "MODIFY the nature of",
            control: "CONTROL the following",
            improve: "IMPROVE functioning by"
          }.each_pair do |field, label|
            if txt = encounter.goals.send(field)
              make_table [[cell(label, txt)]]
            end
          end
        end
      end #}}}

      section 'VI. Methods of monitoring outcomes', if: ->{encounter.functional_status} do #{{{
        make_table [[cell("Current CGI-I Score", format(encounter.functional_status.severity, 'CGII'))]]

        # FIXME change the name of :methods!!! so we can add it to :store_accessor
        if monitoring_meths = encounter.tp_methods
          (monitoring_meths[:methods] || []).each do |meth|
            if cur_meth = monitoring_meths[meth.name]
              make_table [
                [
                  cell(meth.val, ''),
                  cell('Current score', cur_meth.try(:current)),
                  cell('Target score', cur_meth.try(:target))
                ]
              ]
            end
          end
        end
      end #}}}

      pdf.move_down 8

      pdf.text Enc::Encounter::CERTS[:tp], size: 5

      pdf.bounding_box([0, 0], width: pdf.bounds.width, height: 100) do
        if encounter.signer
          name = [encounter.signer.full_name, encounter.signer.degree].join(', ')
        end

        make_table [
          [
            cell("Clinician Name", name),
            cell("Date of treatment plan", date(encounter.referral.try(:service_date)))
          ]
        ]
      end
    end #}}}

    define_generator 'GBH1' do #{{{
      header 'GENERAL BEHAVIORAL HEALTH INTEGRATION (G0323)'

      section "I. Patient Information" do #{{{
        make_table [
          [
            cell("Last Name", patient.last_name),
            cell("First Name", patient.first_name),
            cell("DOB", date(patient.dob))
          ],
          [
            cell("Facility", patient.facility_room),
            cell("Gender", patient.gender),
            cell("Referral initiated by", format(encounter.referral.initiator, 'REFINITIATOR'))
          ],
          [
            cell("Referring MD name", patient.facility.doctors.find(encounter.referral.md_name.name).try(:name)),
            cell("Date of MD order", date(encounter.referral.order_date))
          ]
        ]

        tp_type = 'GBH1TYPE'

        plan_reasons = [cell("This is", format(encounter.referral.plan_type, tp_type))]
        if encounter.referral.plan_type.try(:name) == 'discharge'
          plan_reasons << cell("Reason for discharge", format(encounter.referral.discharge_reason, "TPDISREASONS"))
        end

        make_table [
          [
            cell("Reason for referral", format(encounter.referral.reasons, "REFREASONS"))
          ],
          plan_reasons
        ]
      end #}}}

      section 'II. Assessment', if: ->{encounter.diagnosis && encounter.functional_status} do #{{{
        diag = encounter.diagnosis
        primary = Ref::Icd.where(icd: diag.primary.name).first
        data = [cell("Primary Diagnosis", primary.to_s)]
        if((secname=diag.secondary.try(:name)) && (ref=Ref::Icd.where(icd: secname).first))
          data << cell("Secondary Diagnosis", ref)
        end
        make_table [data]
        make_table [
          [cell("Prognosis", format(diag.prognosis, 'PROGNOSIS'))],
          [cell("Relevant Medical Diagnosis/Condition", diag.medical_conditions)]
        ]

        pdf.move_down 8
        pdf.text "I certify that the patient’s cognitive status is appropriate for psychotherapy", size: 7

        make_table [
          [
            cell("Cognitive screen", format(encounter.functional_status.respondtreatment, 'RESPONDTREATMNT')),
            cell("Score", encounter.functional_status.cognitive_screen, format(encounter.functional_status.respondtreatment_desc, 'RESPNDTREATMNTDESC')),
            cell("Memory/Recall", format(encounter.functional_status.recall, "RECALL"))
          ]
        ]

        if tr_com = encounter.functional_status.respondtreatment_comments
          make_table [[cell("Comments", tr_com)]]
        end
      end #}}}

      section 'III. Facilitating/Coordinating Treatment', if: ->{encounter.problem && encounter.background_history} do #{{{
        pr = encounter.problem
        bg = encounter.background_history

        tp_interventions = 'GBH1INTERVENTIONS'

        make_table [
          [cell("Major target symptom", format(pr.major_target_symptom, 'MAJORTARGETSYM'))],
          [cell("Problem onset", format(pr.onset, 'PROBLEMONSET'))],
          [cell("Problem frequency/intensity", format(pr.frequency, 'PROBLEMFREQ'), format(pr.intensity, 'PROBLEMINTENSITY'))],
          [cell("Other reported problems", format(pr.other, 'PROBLEMSOTHER'))],
          [cell("Treatment plan interventions", format(pr.tp_interventions, tp_interventions))]
        ]

        meds_cells = []
        meds = bg.onpsychmeds
        meds_content = format(meds, 'ONMEDS')
        if meds.name == 'Y'
          meds_content += '; ' + bg.onpsychmeds_medication.to_s
        end
        meds_cells << cell("Psychiatric medication", meds_content)

        if meds.name == 'Y' && (gdr_opt = bg.gdr_plan)
          gdr_content = format(bg.gdr_plan, "GDRPLAN")
          if gdr_opt.name == 'Y'
            gdr_content << " - #{date(bg.gdr_plan_date)}"
          end
          meds_cells << cell("GDR plan in place", gdr_content)
        end
        make_table [meds_cells]

        if meds.name == 'Y' && bg.gdr_plan.try(:name).in?(['Y', 'YND'])
          make_table [[cell("Behavioral interventions expected to target following symptoms related to GDR", bg.gdr_plan_interventions)]]
        end

        if pr.comments_re_goals
          make_table [[cell("Comments re symptoms/interventions", pr.comments_re_goals)]]
        end
      end #}}}

      section 'IV. Behavioral Health Planning', if: ->{encounter.plan} do #{{{
        pl = encounter.plan
        make_table [[cell("Type/amount of psychotherapy service recommended", format(pl.amount_of_service, 'PLANRECOMMENDED'))]]
        if pl.amount_of_service.name == '4'
          make_table [[cell("Reason psychotherapy not recommended", format(pl.not_recommended_reason, 'PLANNOTRECOMMENDED'))]]
        else
          make_table [
            [
              cell("Frequency", format(pl.frequency, 'PLANFREQUENCY')),
              cell('Duration', format(pl.duration, 'PLANDURATION'))
            ]
          ]
          if pl.other_services
            make_table [[cell("Other services recommended", format(pl.other_services, 'PLANOTHERSERVICES'))]]
          end
        end
      end #}}}

      section 'V. Behavioral Health Planning - Continuity of Care', if: -> {encounter.goals} do #{{{
        if encounter.goals
          {
            increase: "INCREASE the frequency of",
            decrease: "DECREASE the frequency of",
            modify: "MODIFY the nature of",
            control: "CONTROL the following",
            improve: "IMPROVE functioning by",
            staff: "Designated coordinating staff member for continuity of care"
          }.each_pair do |field, label|
            if txt = encounter.goals.send(field)
              make_table [[cell(label, txt)]]
            end
          end

          pdf.move_down 8
          pdf.text "Staff apprised of goals and provided oral guidelines and summary of treatment", size: 7
        end
      end #}}}

      section 'VI. Rating Scale', if: ->{encounter.functional_status} do #{{{
        make_table [[cell("Current CGI-I Score", format(encounter.functional_status.severity, 'CGII'))]]

        # FIXME change the name of :methods!!! so we can add it to :store_accessor
        if monitoring_meths = encounter.tp_methods
          (monitoring_meths[:methods] || []).each do |meth|
            if cur_meth = monitoring_meths[meth.name]
              make_table [
                [
                  cell(meth.val, ''),
                  cell('Current score', cur_meth.try(:current)),
                  cell('Target score', cur_meth.try(:target))
                ]
              ]
            end
          end
        end
      end #}}}

      pdf.move_down 8

      pdf.text Enc::Encounter::CERTS[:tp], size: 5

      pdf.bounding_box([0, 0], width: pdf.bounds.width, height: 100) do
        if encounter.signer
          name = [encounter.signer.full_name, encounter.signer.degree].join(', ')
        end

        prep_time = ''
        if encounter.certification.start_time && encounter.certification.end_time
          start_time = encounter.certification.start_time.split(':')
          end_time = encounter.certification.end_time.split(':')

          start_time_hours = start_time[0].to_i
          end_time_hours = end_time[0].to_i
          hours_diff = end_time_hours - start_time_hours

          start_time_minutes = start_time[1].to_i
          end_time_minutes = end_time[1].to_i
          minutes_diff = end_time_minutes - start_time_minutes

          total_minutes_diff = (hours_diff * 60) + minutes_diff

          prep_time = "#{total_minutes_diff} minutes"
        end

        make_table [
          [
            cell("Clinician Name", name),
            cell("Date of behavioral plan", date(encounter.referral.try(:service_date)))
          ],
          [
            cell('Start time', encounter.certification.start_time),
            cell('End time', encounter.certification.start_time),
            cell('Time preparing plan', prep_time),
          ]
        ]
      end
    end #}}}

    define_generator '90853' do #{{{
      header [
        '90853 Group Psychotherapy',
        ('[UNBILLED]' unless encounter.group_billable?)
      ].join(" ")

      section "I. Patient Information" do #{{{
        make_table [
          [
            cell("Last Name", patient.last_name),
            cell("First Name", patient.first_name),
            cell("DOB", date(patient.dob))
          ],
          [
            cell("Facility", patient.facility_room),
            cell("Gender", patient.gender),
            cell("Referral initiated by", format(encounter.referral.initiator, 'REFINITIATOR'))
          ],
          [
            cell("Referring MD name", -> {patient.facility.doctors.find(encounter.referral.md_name.name).try(:name) }),
            cell("Date of MD order", date(encounter.referral.order_date))
          ],
          [
            cell("Medical necessity", format(encounter.referral.medical_necessity, "MEDICALNECESSITY"))
          ]
        ]
      end #}}}

      section "II. Mental Status Examination", if: -> {encounter.functional_status} do #{{{
        fs = encounter.functional_status
        make_table [
          [
            cell("Clinical Global Impression-Severity", format(fs.severity, 'CGIS'))
          ]
        ]

        make_table [
          [
            cell("Orientation Problems", format(fs.orientation, 'ORIENTATION', if: ->(v){ v.name == 'P' })),
            cell("Appearance and Dress", format(fs.appearance, 'DRESS', if: ->(v){ v.name == 'I' }))
          ],
          [
            cell("Motor Activity", format(fs.motor, 'MOTOR', if: ->(v){ v.name == 'R' })),
            cell("Alertness/Concentration", format(fs.alertness, 'ALERTNESS'))
          ],
          [
            cell("Mood", format(fs.mood, 'MOOD', if: ->(v){ v.name == 'A' })),
            cell("Affect", format(fs.affect, 'AFFECT', if: ->(v){ v.name == 'B' }))
          ],
          [
            cell("Communication/Expression", format(fs.expression, 'EXPRESSION', if: ->(v){ v.name == 'B' })),
            cell("Behavioral Style/Attitude", format(fs.attitude, 'ATTITUDE', if: ->(v){ v.name == 'B' }))
          ],
          [
            cell("Judgment/Reasoning", format(fs.reasoning, 'REASONING')),
            cell("Motivation", format(fs.motivation, 'MOTIVATION'))
          ],
        ]

        make_table [[cell("Thought Process", format(fs.thought_process, 'THOUGHTPR'))]]

        th_content = fs.thought_content
        content_cell = if th_content.name != 'A'
          cell("Thought content/preoccupations", format(th_content, 'THOUGHTCONT'))
        else
          content = format(th_content, 'THOUGHTCONT') + " - "
          content += %i(obsessions compulsions phobias hypochondriasis other).map {|label|
            if cont = th_content.send(label)
              [label, cont].join ": "
            end
          }.compact.join '; '

          cell("Thought content/preoccupations", content)
        end

        make_table [[content_cell]]
        make_table [[cell("Memory/Recall", format(fs.recall, "RECALL"))]]
        make_table [
          [
            cell("Intellectual ability", format(fs.intellectual_ability, "INTABILITY")),
            cell("Insight/Awareness of problem", format(fs.insight, "INSIGHT"))
          ]
        ]

        harm = fs.harm
        harm_label = "Expressed threat of harm to self or others"
        if harm.name == 'Y'
          make_table [[cell(harm_label, format(harm.problems, 'EXPRHARM'))]]
        else
          make_table [[cell(harm_label, "No")]]
        end

        make_table [
          [
            cell("Cognitive screen", format(fs.respondtreatment, 'RESPONDTREATMNT'), fs.cognitive_screen, format(fs.respondtreatment_desc, 'RESPNDTREATMNTDESC'))
          ]
        ]

        if fs.note
          make_table [[cell("Note", fs.note)]]
        end

        # TODO can a 90853 have IC?
        #if fs.interactive_complexity.try(:name) == 'Y'
        #  make_table [[cell("Interactive complexity", format(fs.interactive_complexity.problems, 'REASONINTEACTVCOMPLXTY') )]]
        #end
      end #}}}

      section "III. Background and History", if: ->{encounter.background_history} do #{{{
        bg = encounter.background_history
        table_data = [
          [
            cell("Family Status", [format(bg.marital_status, "MARITALSTATUS"), format(bg.family_status, "FAMILYSTATUS")].join('; ')),
            cell("Educational background", format(bg.education_status, "EDUSTATUS"))
          ],

          [
            cell("Social/Occupational background", format(bg.occupational_status, 'OCCUPATION')),
            cell("Place of birth", format(bg.birth_place, 'BIRTHPLACE'))
          ],

          [
            cell("Family Background", format(bg.family_background, 'FAMILYBACKGRND')),
            cell("Raised by", format(bg.raised_by, 'RAISEDBY'))
          ]
        ]

        mental_illness = [cell("History of mental illness", format(bg.hist_mental_ill, 'HISTMETNALILL'))]
        mental_illness << cell("Mental illness comment", bg.history_comment) if bg.history_comment

        table_data << mental_illness

        table_data << [
          cell("Religious/Spiritual status", format(bg.religious_status, 'RELIGIOUSSTATUS'))
        ]
        meds = bg.onpsychmeds
        meds_content = format(meds, 'ONMEDS')
        if meds.name == 'Y'
          meds_content += '; ' + bg.onpsychmeds_medication.to_s
        end
        table_data.last << cell("Psychiatric medication", meds_content)

        make_table table_data

        make_table [[cell("Relevant Medical Condition(s)", bg.medical_conditions)]]

        if bg.note
          make_table [[cell("Comments", bg.note)]]
        end
      end #}}}

      section 'IV. Diagnosis and Prognosis', if: ->{encounter.diagnosis} do #{{{
        diag = encounter.diagnosis
        primary = Ref::Icd.where(icd: diag.primary.name).first
        data = [cell("Primary Diagnosis", primary.to_s)]
        if((secname=diag.secondary.try(:name)) && (ref=Ref::Icd.where(icd: secname).first))
          data << cell("Secondary Diagnosis", ref)
        end
        make_table [data]

        make_table [
          [cell("Prognosis", format(diag.prognosis, 'PROGNOSIS'))]
        ]
      end #}}}

      section 'V. Group Therapy Session' do #{{{
        group_data = encounter.group_data
        make_table [
          [
            cell("Group name", ->{ group_data.name }),
            cell("Number of participants in this session", -> { group_data.session.participants })
          ],
          [ cell("General therapeutic theme for the group", -> { group_data.session.theme} )],
          [ cell("Therapeutic group goal for this session", -> { group_data.session.goal}  )],
          [ cell("Describe how individual problems relate to group theme; describe participation in the group process and any significant changes in overall patient status", -> {group_data.session.description})]
        ]
      end #}}}

      section 'VI. Interventions and Progress' do #{{{
        interventions = encounter.group_data.interventions
        make_table [
          [
            cell("Personal and group dynamics related to session goals discussed", -> {interventions.dynamics}),
            cell("Therapeutic factors focused on this session", -> { format(interventions.therapeutic_factors, 'THERAPEUTICFACTORS') })
          ],
          [ cell("Emotional catharsis, instruction, insight, and support for group in this session", -> {interventions.description} ) ],
          [ cell("Group progress to date", -> { format(interventions.cgii, 'CGII') }) ]
        ]

        if (notes=encounter.group_data.confidential_notes).present? && !omit_note?
          rows = [[cell("Confidential notes for patient(s)", "")]]
          notes.each do |note|
            rows << [cell("*", note)]
          end
          make_table rows
        end

        if (notes=encounter.group_data.individual_notes).present?
          rows = [[cell("Individual notes", "")]]
          notes.each do |note|
            rows << [cell("*", note)]
          end
          make_table rows
        end
      end #}}}

      footer
    end #}}}

    define_generator '96116' do #{{{
      header encounter.testing_header_with_code

      section "Comprehensive Report", own_page: true do #{{{
        ref = encounter.referral

        info_table = [
          [ cell("Name", patient.full_name) ],
          [ cell("DOB", date(patient.dob)) ],
          [ cell("Billing Date", date(encounter.service_date)) ],
          [ cell("History, Background & Behavioral Observations", ref.observations) ],
          [ cell("Reason for Referral", format( ref.reasons, 'REFREASONS9611X' )) ],
          [ cell("Services conducted", format( ref.services_conducted, 'SRV9611X' )) ]
        ]

        if "7".in?(ref.services_conducted.map(&:name))
          info_table << [ cell( "WAIS subtest(s) and version administered", ref.wais_extra ) ]
        end

        if "10".in?(ref.services_conducted.map(&:name))
          info_table << [ cell( "Graphomotor", ref.graphomotor_extra ) ]
        end

        [
          [ cell("Code for examination", ref.code) ],
          [ cell("Total evaluation time", ref.minutes) ],
          [ cell("Evaluation dates", ref.eval_dates) ],
        ].each do |row|
          info_table << row
        end

        if ref.scoring_minutes.to_i > 0
          info_table << [ cell("Total administration and scoring time (by psychologist)", ref.scoring_minutes) ]
          info_table << [ cell("Administration and scoring dates (by psychologist)", ref.scoring_dates) ]
        end

        if ref.tech_scoring_minutes.to_i > 0
          info_table << [ cell("Total administration and scoring time (by technician)", ref.tech_scoring_minutes) ]
          info_table << [ cell("Administration and scoring dates (by psychologist)", ref.tech_scoring_dates) ]
        end

        if ref.computer_test_count.to_i > 0
          info_table << [ cell("Number of computerized tests administered", ref.computer_test_count) ]
          info_table << [ cell("Computerized testing dates", ref.computer_dates) ]
          info_table << [ cell("Names of computerized tests", ref.computer_names) ]
        end

        info_table << [ cell("Present evaluation", ref.evaluation) ]

        make_table info_table

        diag = encounter.diagnosis
        diag_table = [[ cell("Final Diagnosis", '') ]]
        diags = [ Ref::Icd.where(icd: diag.primary.name).first ]

        if sec_diag_name = diag.secondary.try(:name)
          diags << Ref::Icd.where(icd: sec_diag_name).first
        end

        diags.each do |diagnosis|
          diag_table << [ diagnosis.to_s ]
        end

        make_table diag_table

        make_table [
          [ cell("Recommendations for interventions", ref.recommendations) ]
        ]

      end  #}}}

      section "Background Information", own_page: true do #{{{ 
        bg = encounter.background_history

        qs = [
          %Q{Is there a formal diagnosis of dementia in the medical record?},
          %Q{Formal diagnosis of other organic brain condition?},
          %Q{Is there any record of previous psychological testing?},
          %Q{Are there any objective data in the medical record related to the following cognitive functions: Decision making; Social judgment; memory; reasoning; non-verbal skills; language skills},
          %Q{Are there any objective data in the medical record related to the following emotional/behavioral functions: Anxiety, adjustment, depression, behavioral issues},
          %Q{Will: “the information derived would be expected to impact significantly the management of the patient? Examples would include: A significant change in the patient’s condition; The need to evaluate a patient’s capacity to function in a given situation or environment; The need to specifically tailor therapeutic and or compensatory techniques to particular aspects of the patient’s pattern of strengths and disabilities},
          %Q{Is this evaluation needed in order to determine the patient’s ability and capacity to make independent decisions and to understand their consequences?},
        ]

        testing_note_bg_qs[0..6].zip(qs).each do |q|
          make_table [[ cell(q[1], testing_note_bg_format(q[0], bg)) ]]
        end

        if bg.eval_needed == "Yes"
          label = "Explain circumstances related to need for capacity determination"
          make_table [[ cell(label, bg.extra.eval_needed) ]]
        end

        make_table [[ cell("Is further neuropsychological testing required?", testing_note_bg_format(:more_test, bg)) ]]
      end #}}}

      section "Summary Profile" do #{{{
        st = encounter.functional_status

        make_table [
          [ cell("Name", encounter.patient.full_name) ],
          [ cell("DOB", date(encounter.patient.dob)) ],
          [ cell("Billing Date", date(encounter.service_date)) ],
          [ cell("Psychologist", encounter.signer.name_with_title) ]
        ]

        pdf.move_down 15
        pdf.stroke_horizontal_rule
        pdf.move_down 15

        pdf.text "Level of Impairment", style: :bold_italic, size: 16
        pdf.move_down 5

        impairment_labels = [
          %Q{General intellectual ability},
          %Q{Overall functional skills},
          %Q{Language skills},
          %Q{Attention-Concentrationtration skill},
          %Q{Reasoning & judgment},
          %Q{Short-term/working memory},
          %Q{Long-term memory},
          %Q{Motor speed},
          %Q{Abstraction & problem solving},
          %Q{Non-verbal and perceptual integrity},
        ]

        score_blk = ->(base, item) do
          st[base] ||= {}
          score = st[base][item] || 0
          case score
          when 0
            "0 (None)"
          when 1..3
            "#{score} (Mild)"
          when 4..7
            "#{score} (Moderate)"
          else
            "#{score} (Severe)"
          end
        end

        testing_note_impairments.each.with_index do |imp,idx|
          val = score_blk[:impairments, imp]
          make_table [[ cell(impairment_labels[idx], val) ]]
        end

        pdf.move_down 15
        pdf.stroke_horizontal_rule
        pdf.move_down 15

        make_table [[ cell("Capacity for independent functioning", format(st.independent_capacity, 'CAPFUNC')) ]]
        unless st.independent_capacity_comments.blank?
          make_table [[ cell("Comments", st.independent_capacity_comments) ]]
        end

        pdf.move_down 5

        make_table [[ cell("Estimated duration of current status", format(st.duration, 'STATDUR')) ]]
        unless st.duration_comment.blank?
          make_table [[ cell("Comment", st.duration_comment) ]]
        end

        pdf.move_down 15
        pdf.stroke_horizontal_rule
        pdf.move_down 15

        pdf.text "Degree of Interference", style: :bold_italic, size: 16
        pdf.move_down 5

        interference_lables = [
          %Q{Emotional or psychological factors},
          %Q{Organic factors},
          %Q{Evidence of progressive dementia},
          %Q{Evidence of MCI (Mild cognitive impairment)}
        ]

        testing_note_interferences.each.with_index do |int,idx|
          val = score_blk[:interferences, int]
          make_table [[ cell(interference_lables[idx], val) ]]
        end

        pdf.move_down 15
        pdf.stroke_horizontal_rule
        pdf.move_down 15

        make_table [[ cell("Comments", st.extra_comments) ]]
        pdf.move_down 10

        pdf.text encounter.signer.name_with_title, style: :bold, size: 14

      end #}}}
    end #}}}

    private

    def each_page(encounter)
      @encounter = encounter
      @patient = encounter.patient
      @generator = self.class.generators[encounter.cpt_encounter_code]
      instance_eval(&@generator)
      addendumize unless omit_addendum?
      pdf.start_new_page
    end

    def footer
      if encounter.signer
        if encounter.signer.incident_to_provider?
          name = [encounter.signer.linked_provider.full_name, encounter.signer.linked_provider.degree].join(', ')
        else
          name = [encounter.signer.full_name, encounter.signer.degree].join(', ')
        end
      end

      if cert = encounter.certification
        start_time = time(cert.start_time)
        end_time = time(cert.end_time)
      end

      if sd = encounter.referral.try(:service_date)
        svc_date = date(sd)
      end

      pdf.bounding_box([0, 20], width: pdf.bounds.width, height: 100) do
        table_sections = [
          [
            cell("Clinician Name", name),
            cell("Date of Service", svc_date),
            cell("Date Signed", date(encounter.signed_on.to_s))
          ],

          [
            cell("Start time", start_time),
            cell("End time", end_time),
            cell("Total minutes", session_minutes)
          ]
        ]

        if encounter.incident_to_provider.present?
          name = [encounter.incident_to_provider.full_name, encounter.incident_to_provider.degree].join(', ')
          table_sections << [
            cell("Incident to clinician name", name)
          ]
        end

        make_table table_sections

        if encounter.incident_to_provider.present?
          pdf.text "Clinical service is provided under general supervision by the psychologist clinician Supervision is provided on a regular basis and documented by the psychologist clinician.", size: 7
        end
      end
    end

    def addendumize
      return unless encounter.addendums.count > 0

      pdf.start_new_page

      header "Addendums for #{patient.full_name} - Service Date: #{date(encounter.referral.try(:service_date))}"

      data = encounter.addendums.map do |addendum|
        [cell("[#{date(addendum.created_at)}][#{addendum.user.full_name}]", addendum.note)]
      end

      make_table data
    end

  end
end

# vim: set foldmethod=marker
