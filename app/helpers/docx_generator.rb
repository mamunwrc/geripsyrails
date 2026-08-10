module DocxGenerator
  class Encounter
    include ExportHelpers

    class << self
      def define_generator(*types, &blk)
        types.each do |type|
          generators[type] = blk
        end
      end

      def generators
        @generators ||= {}
      end

      def generate(encounter, opts={})
        generator = new(encounter, opts)
        generator.generate!
      end
    end

    def initialize(encounter, opts={})
      @context = OpenStruct.new({
        long_cert: Enc::Encounter::CERTS[:long],
        short_cert: Enc::Encounter::CERTS[:short],
        tp_cert: Enc::Encounter::CERTS[:tp],
        group_cert: Enc::Encounter::CERTS[:group]
      })
      @encounter = encounter
      @lookups = Ref::Lookup.all.group_by(&:keyprefix)
      @type = opts.fetch(:type, 'full')
      @user = opts[:user]
      @templates = {}
    end

    attr_reader :encounter, :context, :lookups

    def generate!
      generator = self.class.generators[encounter.cpt_encounter_code]
      instance_eval(&generator)
      if !omit_addendum? && encounter.addendums.any? && @templates[:full]
        addendumize!
      end
      self
    end

    def render
      Sablon.template(template_path).render_to_string context.to_h
    end

    private

    def templates(opts={})
      @templates = opts
    end

    def template
      if !omit_addendum? && encounter.addendums.any? && @templates[:full]
        @templates[:full]
      else
        @templates[:default]
      end
    end

    def template_path
      raise "No template!" unless template
      File.join Rails.root, 'docx', template
    end

    def section(name, opts={})
      can_run = if(_if = opts[:if])
        !!_if[]
      else
        true
      end

      return unless can_run

      sec = OpenStruct.new
      @current_section = sec
      yield if block_given?
      context[name] = sec
    end

    def bool_field(name, val)
      @current_section[name] = val
    end

    def field(name, *vals)
      val = vals.map {|v|
        Proc === v ? v[] : v
      }.join('; ')
    rescue => e
      Rails.logger.error "ERROR | #{e.class} ~> #{e.message} | \n#{e.backtrace.join("\n")}"
      val = ''
    ensure
      @current_section[name] = val
    end

    def add_default_footer!
      section :footer do
        if dr = encounter.signer
          field :dr_name, [dr.full_name, dr.degree].join(', ')
          field :date_signed, -> { date(encounter.signed_on.to_s) }
        end

        if cert = encounter.certification
          field :start_time, time(cert.start_time)
          field :end_time, time(cert.end_time)
          field :session_mins, session_minutes
        end

        if sd = encounter.referral.try(:service_date)
          field :service_date, date(sd)
        end
      end
    end

    def addendumize!
      return unless encounter.addendums.any?

      context.has_addendums = true
      section :addendum do
        field :name, -> { encounter.patient.full_name }
        field :service_date, -> { date(encounter.referral.try(:service_date)) }
      end
      context.addendums = encounter.addendums.map {|addendum|
        {
          date: date(addendum.created_at),
          provider: addendum.user.full_name,
          body: addendum.note
        }
      }
    end

    define_generator '90791' do #{{{
      templates({
        default: '90791.template.docx',
        full: '90791.template.docx'
      })

      section :header do
        code = "90791"
        code << ",90785" if encounter.has_interactive_complexity?
        field :code, code
      end

      section :patient do
        has_hiatus =
          begin
            ref = encounter.referral
            ref.hiatus.try(:name) == 'Y' && ref.hiatus_reason.try(:val).present?
          rescue
            false
          end

        build_hiatus = ->(sec) {
          reason = sec.hiatus_reason
          text = format(reason, 'HAS90791THISYEAR')
          if reason.name.in?(%w(hospitalized transferred))
            d =
              if hdate = sec.hiatus_date
                date(hdate)
              else
                'date unkown'
              end
            [text, d].join ' '
          else
            text
          end
        }

        field :has_hiatus,        has_hiatus
        if has_hiatus
          field :hiatus, build_hiatus[encounter.referral]
          if encounter.referral.hiatus_comment.present?
            field :has_hiatus_com, true
            field :hiatus_comment, encounter.referral.hiatus_comment
          end
        end

        field :last_name,         -> { encounter.patient.last_name }
        field :first_name,        -> {encounter.patient.first_name}
        field :dob,               date(encounter.patient.dob)
        field :gender,            -> { encounter.patient.gender }
        field :facility,          -> { encounter.patient.facility_room }
        field :referrer,          format(encounter.referral.initiator,                                                       'REFINITIATOR')
        field :md_name,           -> {encounter.patient.facility.doctors.find(encounter.referral.md_name.name).try(:name) }
        field :order_date,        date(encounter.referral.order_date)
        field :referral_reasons,  format(encounter.referral.reasons,                                                         'REFREASONS')
        field :medical_necessity, format(encounter.referral.medical_necessity,                                               'MEDICALNECESSITY')
      end

      section :status do
        fs = encounter.functional_status

        field :cgis,            format(fs.severity,        'CGIS')
        field :orientation,     format(fs.orientation,     'ORIENTATION', if: ->(v){ v.name == 'P' })
        field :appearance,      format(fs.appearance,      'DRESS', if: ->(v){ v.name == 'I' })
        field :motor,           format(fs.motor,           'MOTOR', if: ->(v){ v.name == 'R' })
        field :alertness,       format(fs.alertness,       'ALERTNESS')
        field :mood,            format(fs.mood,            'MOOD', if: ->(v){ v.name == 'A' })
        field :affect,          format(fs.affect,          'AFFECT', if: ->(v){ v.name == 'B' })
        field :expression,      format(fs.expression,      'EXPRESSION', if: ->(v){ v.name == 'B' })
        field :attitude,        format(fs.attitude,        'ATTITUDE', if: ->(v){ v.name == 'B' })
        field :reasoning,       format(fs.reasoning,       'REASONING')
        field :motivation,      format(fs.motivation,      'MOTIVATION')
        field :thought_process, format(fs.thought_process, 'THOUGHTPR')

        th_content = fs.thought_content
        th_cont_val = format(th_content, 'THOUGHTCONT')
        if th_content.name == 'A'
          th_cont_val += %i(obsessions compulsions phobias hypochondriasis other).map {|label|
            if cont = th_content.send(label)
              [label, cont].join ': '
            end
          }.compact.join '; '
        end
        field :thought_content, th_cont_val

        field :recall,      format(fs.recall,               'RECALL')
        field :int_ability, format(fs.intellectual_ability, 'INTABILITY')
        field :insight,     format(fs.insight,              'INSIGHT')

        harm_cont = if fs.harm == 'Y'
          format(fs.harm.problems, 'EXPRHARM')
        else
          'No'
        end
        field :harm, harm_cont

        field :cognitive_screen, format(fs.respondtreatment, 'RESPONDTREATMNT'), fs.cognitive_screen, format(fs.respondtreatment_desc, 'RESPNDTREATMNTDESC')

        if fs.note
          field :note, fs.note
        end

        if fs.interactive_complexity.try(:name) == 'Y'
          field :interactive_complexity, format(fs.interactive_complexity.problems, 'REASONINTEACTVCOMPLXTY')
        end
      end

      section :background do
        bg = encounter.background_history

        field :family_status,     format(bg.marital_status,      "MARITALSTATUS"), format(bg.family_status, "FAMILYSTATUS")
        field :education,         format(bg.education_status,    "EDUSTATUS")
        field :occupation,        format(bg.occupational_status, 'OCCUPATION')
        field :birthplace,        format(bg.birth_place,         'BIRTHPLACE')
        field :family_background, format(bg.family_background,   'FAMILYBACKGRND')
        field :raisedby,         format(bg.raised_by,           'RAISEDBY')
        field :mental_illness,    format(bg.hist_mental_ill,     'HISTMETNALILL')

        if bg.history_comment
          field :history_cmnt, bg.history_comment
        end

        field :religious_status, format(bg.religious_status, 'RELIGIOUSSTATUS')

        meds = bg.onpsychmeds
        meds_content = format(meds, 'ONMEDS')
        if meds.name == 'Y'
          meds_content += '; ' + bg.onpsychmeds_medication.to_s
          if gdr_opt = bg.gdr_plan
            gdr_content = format(gdr_opt, 'GDRPLAN')
            gdr_content << " - #{date(bg.gdr_plan_date)}" if gdr_opt.name == 'Y'
            field :gdr_plan, gdr_content
          end
        end
        field :medication, meds_content

        field :medical_conditions, bg.medical_conditions
      end

      section :problem do
        pr = encounter.problem

        if pr
          field :onset, format(pr.onset, 'PROBLEMONSET')
          field :freq, format(pr.frequency, 'PROBLEMFREQ'), format(pr.intensity, 'PROBLEMINTENSITY')
          field :other, format(pr.other, 'PROBLEMSOTHER')
          field :impression, format(pr.staffimpression, 'STAFFIMPRESSION')
          field :stressors, format(pr.precipstressors, 'PRECIPSTRESSORS')
          field :observation, pr.observation
        end
      end

      section :diagnosis do
        diag = encounter.diagnosis || Hashie::Mash.new
        primary = Ref::Icd.where(icd: diag.primary.try(:name)).first

        field :primary, primary.to_s
        if((secname=diag.secondary.try(:name)) && (ref=Ref::Icd.where(icd: secname).first))
          field :secondary, ref
        end
        field :prognosis, format(diag.prognosis, 'PROGNOSIS')

        if diag.comment
          field :note, diag.comment
        end
      end

      refreasons = encounter.referral.reasons || []
      if refreasons.find {|reason| reason.name == "1"} # has initial plan
        context.has_section_plan = true
        section :plan do
          pl = encounter.plan
          field :amount_of_service, format(pl.amount_of_service, 'PLANRECOMMENDED')

          if pl.amount_of_service.name == '4'
            field :not_recommended, true
            field :not_recommended_reason, format(pl.not_recommended_reason, 'PLANNOTRECOMMENDED')
          else
            field :is_recommended, true
            field :freq, format(pl.frequency, 'PLANFREQUENCY')
            field :duration, format(pl.duration, 'PLANDURATION')

            if pl.other_services
              field :other_services, format(pl.other_services, 'PLANOTHERSERVICES')
            end
          end
        end
      end

      if refreasons.find {|reason| reason.name == "2"} # has competency findings
        context.has_competency = true
        section :competency do
          comp = encounter.competency
          field :findings, format(comp.findings, 'COMPETENCYFINDINGS')
          if comp.comment
            field :note, comp.comment
          end
        end
      end

      context.has_cert_statement_long = encounter.has_long_cert?
      context.has_cert_statement_short = encounter.has_short_cert?

      add_default_footer!
    end #}}}

    define_generator '90839' do #{{{
      templates({
        default: '90839.template.docx',
        full: '90839.template.docx'
      })

      section :header do
        code = "90839"
        code << ",90840" if encounter.has_90840?
        field :code, code
      end

      section :patient do
        field :last_name,         -> { encounter.patient.last_name }
        field :first_name,        -> {encounter.patient.first_name}
        field :dob,               date(encounter.patient.dob)
        field :gender,            -> { encounter.patient.gender }
        field :facility,          -> { encounter.patient.facility_room }
        field :referrer,          format(encounter.referral.initiator,                                                       'REFINITIATOR')
        field :md_name,           -> {encounter.patient.facility.doctors.find(encounter.referral.md_name.name).try(:name) }
        field :order_date,        date(encounter.referral.order_date)
      end

      section :status do
        fs = encounter.functional_status

        field :cgis,            format(fs.severity,        'CGIS')
        field :orientation,     format(fs.orientation,     'ORIENTATION', if: ->(v){ v.name == 'P' })
        field :appearance,      format(fs.appearance,      'DRESS', if: ->(v){ v.name == 'I' })
        field :motor,           format(fs.motor,           'MOTOR', if: ->(v){ v.name == 'R' })
        field :alertness,       format(fs.alertness,       'ALERTNESS')
        field :mood,            format(fs.mood,            'MOOD', if: ->(v){ v.name == 'A' })
        field :affect,          format(fs.affect,          'AFFECT', if: ->(v){ v.name == 'B' })
        field :expression,      format(fs.expression,      'EXPRESSION', if: ->(v){ v.name == 'B' })
        field :attitude,        format(fs.attitude,        'ATTITUDE', if: ->(v){ v.name == 'B' })
        field :reasoning,       format(fs.reasoning,       'REASONING')
        field :motivation,      format(fs.motivation,      'MOTIVATION')
        field :thought_process, format(fs.thought_process, 'THOUGHTPR')

        th_content = fs.thought_content
        th_cont_val = format(th_content, 'THOUGHTCONT')
        if th_content.name == 'A'
          th_cont_val += %i(obsessions compulsions phobias hypochondriasis other).map {|label|
            if cont = th_content.send(label)
              [label, cont].join ': '
            end
          }.compact.join '; '
        end
        field :thought_content, th_cont_val

        field :recall,      format(fs.recall,               'RECALL')
        field :int_ability, format(fs.intellectual_ability, 'INTABILITY')
        field :insight,     format(fs.insight,              'INSIGHT')

        harm_cont = if fs.harm == 'Y'
          format(fs.harm.problems, 'EXPRHARM')
        else
          'No'
        end
        field :harm, harm_cont

        field :cognitive_screen, format(fs.respondtreatment, 'RESPONDTREATMNT'), fs.cognitive_screen, format(fs.respondtreatment_desc, 'RESPNDTREATMNTDESC')

        if fs.note
          field :note, fs.note
        end
      end

      section :background do
        bg = encounter.background_history

        field :family_status,     format(bg.marital_status,      "MARITALSTATUS"), format(bg.family_status, "FAMILYSTATUS")
        field :education,         format(bg.education_status,    "EDUSTATUS")
        field :occupation,        format(bg.occupational_status, 'OCCUPATION')
        field :birthplace,        format(bg.birth_place,         'BIRTHPLACE')
        field :family_background, format(bg.family_background,   'FAMILYBACKGRND')
        field :raisedby,         format(bg.raised_by,           'RAISEDBY')
        field :mental_illness,    format(bg.hist_mental_ill,     'HISTMETNALILL')

        if bg.history_comment
          field :history_cmnt, bg.history_comment
        end

        field :religious_status, format(bg.religious_status, 'RELIGIOUSSTATUS')

        meds = bg.onpsychmeds
        meds_content = format(meds, 'ONMEDS')
        if meds.name == 'Y'
          meds_content += '; ' + bg.onpsychmeds_medication.to_s
        end
        field :medication, meds_content

        field :medical_conditions, bg.medical_conditions
      end

      section :problem do
        pr = encounter.problem

        if pr
          field :intensity, format(pr.intensity, 'PROBLEMINTENSITY')
          field :state, format(pr.crisis_state, 'CRISISSTATES')
          field :history, format(pr.crisis_history, 'CRISISHIST')
          field :distress, format(pr.crisis_distress, 'CRISISDISTRESS')
          if pr.crisis_comment
            field :cmnts, pr.crisis_comment
          end
        end
      end

      section :diagnosis do
        diag = encounter.diagnosis || Hashie::Mash.new
        primary = Ref::Icd.where(icd: diag.primary.try(:name)).first

        field :primary, primary.to_s
        if((secname=diag.secondary.try(:name)) && (ref=Ref::Icd.where(icd: secname).first))
          field :secondary, ref
        end
        field :prognosis, format(diag.prognosis, 'PROGNOSIS')

        if diag.comment
          field :note, diag.comment
        end
      end

      section :plan do
        pl = encounter.plan
        field :psych, format(pl.crisis_psychotherapy, "CRISISPSYCH")
        field(:psych_cmnt, pl.crisis_psychotherapy_comment) if pl.crisis_psychotherapy_comment
        field :mobi, format(pl.crisis_mobilization, "CRISISMOBILIZATION")
        field(:mobi_cmnt, pl.crisis_mobilization_comment) if pl.crisis_mobilization_comment
        field :summary, pl.crisis_intervention_summary

        field :risk, format(pl.crisis_risk_assessment, "CRISISRISK")
        field(:risk_cmnt, pl.crisis_risk_assessment_comment) if pl.crisis_risk_assessment_comment

        rec = format(pl.crisis_recommendations, 'CRISISRECS')
        if pl.crisis_recommendations.try(:name) == '1'
          rec = [rec, pl.crisis_recommendation_until] * " "
        end
        field :recommendations, rec

        if pl.crisis_additional_time.try(:name) == 'Y'
          field :additional_time, format(pl.crisis_additional_time_minutes, 'CRISISTIME')
        end
      end

      context.has_cert_statement_short = true

      add_default_footer!
    end #}}}

    define_generator '90853' do #{{{
      templates({
        default: '90853.template.docx',
        full: '90853.template.docx'
      })

      section :header do
        code = ["90853 Group Psychotherapy", ('[UNBILLED]' unless encounter.group_billable?)].compact.join(" ")
        field :code, code
      end

      section :patient do
        field :last_name,         -> { encounter.patient.last_name }
        field :first_name,        -> {encounter.patient.first_name}
        field :dob,               date(encounter.patient.dob)
        field :gender,            -> { encounter.patient.gender }
        field :facility,          -> { encounter.patient.facility_room }
        field :referrer,          format(encounter.referral.initiator,                                                       'REFINITIATOR')
        field :md_name,           -> {encounter.patient.facility.doctors.find(encounter.referral.md_name.name).try(:name) }
        field :order_date,        date(encounter.referral.order_date)
        field :medical_necessity, format(encounter.referral.medical_necessity,                                               'MEDICALNECESSITY')
      end

      section :status do
        fs = encounter.functional_status

        field :cgis,            format(fs.severity,        'CGIS')
        field :orientation,     format(fs.orientation,     'ORIENTATION', if: ->(v){ v.name == 'P' })
        field :appearance,      format(fs.appearance,      'DRESS', if: ->(v){ v.name == 'I' })
        field :motor,           format(fs.motor,           'MOTOR', if: ->(v){ v.name == 'R' })
        field :alertness,       format(fs.alertness,       'ALERTNESS')
        field :mood,            format(fs.mood,            'MOOD', if: ->(v){ v.name == 'A' })
        field :affect,          format(fs.affect,          'AFFECT', if: ->(v){ v.name == 'B' })
        field :expression,      format(fs.expression,      'EXPRESSION', if: ->(v){ v.name == 'B' })
        field :attitude,        format(fs.attitude,        'ATTITUDE', if: ->(v){ v.name == 'B' })
        field :reasoning,       format(fs.reasoning,       'REASONING')
        field :motivation,      format(fs.motivation,      'MOTIVATION')
        field :thought_process, format(fs.thought_process, 'THOUGHTPR')

        th_content = fs.thought_content
        th_cont_val = format(th_content, 'THOUGHTCONT')
        if th_content.try(:name) == 'A'
          th_cont_val += %i(obsessions compulsions phobias hypochondriasis other).map {|label|
            if cont = th_content.send(label)
              [label, cont].join ': '
            end
          }.compact.join '; '
        end
        field :thought_content, th_cont_val

        field :recall,      format(fs.recall,               'RECALL')
        field :int_ability, format(fs.intellectual_ability, 'INTABILITY')
        field :insight,     format(fs.insight,              'INSIGHT')

        harm_cont = if fs.harm == 'Y'
          format(fs.harm.problems, 'EXPRHARM')
        else
          'No'
        end
        field :harm, harm_cont

        field :cognitive_screen, format(fs.respondtreatment, 'RESPONDTREATMNT'), fs.cognitive_screen, format(fs.respondtreatment_desc, 'RESPNDTREATMNTDESC')

        if fs.note
          field :note, fs.note
        end

        # TODO can 90853 have IC?
        #if fs.interactive_complexity.try(:name) == 'Y'
        #  field :interactive_complexity, format(fs.interactive_complexity.problems, 'REASONINTEACTVCOMPLXTY')
        #end
      end

      section :background do
        bg = encounter.background_history

        field :family_status,     format(bg.marital_status,      "MARITALSTATUS"), format(bg.family_status, "FAMILYSTATUS")
        field :education,         format(bg.education_status,    "EDUSTATUS")
        field :occupation,        format(bg.occupational_status, 'OCCUPATION')
        field :birthplace,        format(bg.birth_place,         'BIRTHPLACE')
        field :family_background, format(bg.family_background,   'FAMILYBACKGRND')
        field :raisedby,         format(bg.raised_by,           'RAISEDBY')
        field :mental_illness,    format(bg.hist_mental_ill,     'HISTMETNALILL')

        if bg.history_comment
          field :history_cmnt, bg.history_comment
        end

        field :religious_status, format(bg.religious_status, 'RELIGIOUSSTATUS')

        meds = bg.onpsychmeds
        meds_content = format(meds, 'ONMEDS')
        if meds.name == 'Y'
          meds_content += '; ' + bg.onpsychmeds_medication.to_s
        end
        field :medication, meds_content

        field :medical_conditions, bg.medical_conditions
      end

      section :diagnosis do
        diag = encounter.diagnosis || Hashie::Mash.new
        primary = Ref::Icd.where(icd: diag.primary.try(:name)).first
        field :primary, primary.to_s
        if((secname=diag.secondary.try(:name)) && (ref=Ref::Icd.where(icd: secname).first))
          field :secondary, ref
        end

        field :prognosis, format(diag.prognosis, 'PROGNOSIS')
      end

      section :session do
        group_data = encounter.group_data
        sesh = group_data.try(:session)

        field :group_name,   -> { group_data.name }
        field :participants, -> { sesh.participants }
        field :theme,        -> { sesh.theme }
        field :goals,        -> { sesh.goal }
        field :desc,         -> { sesh.description }
      end

      section :interventions do
        int     = encounter.group_data.try(:interventions)
        notes   = encounter.group_data.individual_notes
        c_notes = encounter.group_data.confidential_notes

        field :dynamics,     -> { int.dynamics }
        field :factors,      -> { format(int.therapeutic_factors, 'THERAPEUTICFACTORS') }
        field :desc,         -> { int.description }
        field :cgii,         -> { format(int.cgii, 'CGII') }
        @current_section[:has_confidential] = !omit_note? && c_notes.present?
        @current_section[:has_notes] = notes.present?
        @current_section[:notes] = notes
        @current_section[:c_notes] = c_notes
      end

      add_default_footer!
    end #}}}


    define_generator '90832', '98966' do #{{{

      if encounter.cpt_encounter_code == '98966'
        templates({
          default: '98966.template.docx',
          full: '98966.full.template.docx'
        })
      else
        templates({
          default: '90832.template.docx',
          full: '90832.full.template.docx'
        })
      end

      context.header = encounter.follow_up_header

      section :patient do
        field :last_name,  -> { encounter.patient.last_name }
        field :first_name, -> {encounter.patient.first_name}
        field :dob,        date(encounter.patient.dob)
        field :gender,     -> { encounter.patient.gender }
        field :facility,   -> { encounter.patient.facility_room }
      end

      section :status do
        fs = encounter.functional_status
        field :cgis,            format(fs.severity,        'CGIS')
        field :attitude,        format(fs.attitude,        'ATTITUDE', if: ->(v){ v.name == 'B' })

        harm_cont = if fs.harm == 'Y'
          format(fs.harm.problems, 'EXPRHARM')
        else
          'No'
        end
        field :harm, harm_cont

        status_cont = if fs.status_changed == 'Y'
          "Yes - #{fs.status_changed.freetext}"
        else
          'No'
        end
        field :status, status_cont
        field :cognitive_screen, format(fs.respondtreatment, 'RESPONDTREATMNT'), fs.cognitive_screen, format(fs.respondtreatment_desc, 'RESPNDTREATMNTDESC')
        if fs.interactive_complexity.try(:name) == 'Y'
          field :interactive_complexity, format(fs.interactive_complexity.problems, 'REASONINTEACTVCOMPLXTY')
        end
      end

      section :background do
        bg = encounter.background_history

        %i(status_changed meds_changed condition_changed).each do |label|
          if( (val=encounter.background_history.send(label)).try(:name) == 'Y' )
            field label, "Yes - #{val.freetext}"
          else
            field label, 'No'
          end
        end

        if 'Y'.in?([bg.onpsychmeds.try(:name), bg.meds_changed.name]) && (gdr_opt=bg.gdr_plan)
          gdr_content = format(bg.gdr_plan, "GDRPLAN")
          if gdr_opt.name == 'Y'
            gdr_content << " - #{date(bg.gdr_plan_date)}"
          end
          gdr_content << " --- see treatment plan for behavioral interventions"
          field :gdr_plan, gdr_content
        end

        field :note, encounter.background_history.note
      end

      section :diagnosis do
        diag = encounter.diagnosis || Hashie::Mash.new
        primary = Ref::Icd.where(icd: diag.primary.try(:name)).first
        field :primary, primary.to_s
        if((secname=diag.secondary.try(:name)) && (ref=Ref::Icd.where(icd: secname).first))
          field :secondary, ref
        end

        field :general_goals, diag.general_goals
        field :session_goals, diag.session_goals
        field :prognosis, format(diag.prognosis, 'PROGNOSIS')
      end

      section :problem do #target symptoms
        pr = encounter.problem
        field :major_target_symptom, format(pr.major_target_symptom, 'MAJORTARGETSYM')
        field :onset, format(pr.onset, 'PROBLEMONSET')
        field :freq, format(pr.frequency, 'PROBLEMFREQ'), format(pr.intensity, 'PROBLEMINTENSITY')
        field :other, format(pr.other, 'PROBLEMSOTHER')
      end

      section :therapeutic_communication do
        tc = encounter.therapeutic_communication

        field :service, format(tc.service_conducted, 'SERVICECONDUCTED')

        if tc.service_conducted.try(:name).in?(%w(8 9)) # family therapy
          field :has_family_therapy, true
          field :therapeutic_focus, format(tc.therapeutic_focus, 'THERAPYFOCUS')
          if tc.therapeutic_comments
            field :focus_note, tc.therapeutic_comments.try(:maladaptive), tc.therapeutic_comments.try(:assist)
          end
        else
          field :not_family_therapy, true
          field :modalities, format(tc.modalities, 'MODALITIES')
          field :therapy_attempt, format(tc.therapy_attempted_to, 'THERAPYATTEMPT')
        end

        if tc.family_present.try(:name) == 'Y'
          field :family_present, tc.family_present.try(:member_name), tc.family_present.try(:member_relationship)
        end
      end

      section :progress do
        pr = encounter.progress
        field :session, format(pr.session, 'SESSIONPROG')
        field :monitormech, format(pr.monitoring_mechanisms, 'MONITORMECH')
        field :severity, pr.severity, pr.severity_comments
        field :reason, pr.reason
        field :cgii, format(pr.cgii, 'CGII')
        field :freq, format(pr.frequency, 'PLANFREQUENCY')
        field :duration, format(pr.duration, 'PROGDURATION')

        unless encounter.family_therapy?
          field :isnt_family_therapy, true
          field(:notes, pr.notes)
        else
          field :is_family_therapy, true
          field :family_notes,format(pr.family_notes, 'FAMTHERAPYATTEMPT')

          unless omit_note?
            field :note, pr.family_notes_comments.try(:observe), pr.family_notes_comments.try(:assess)
          end
        end

        field(:symptom_notes, pr.symptom_notes) if pr.symptom_notes && !omit_note?
      end

      add_default_footer!
    end #}}}

    define_generator '96116' do #{{{
      templates default: '9611x.template.docx', full: '9611x.template.docx'

      section :report do
        ref = encounter.referral

        dx_parts = ->(priority="primary") do
          if dx = encounter.diagnosis[priority]
            # need code + description
            # description may have dash
            [
              dx.name,
              dx.val.split("-")[1..-1].join("-")
            ].map(&:upcase)
          end
        end

        field :header,        encounter.testing_header
        field :patient_name,  encounter.patient.full_name
        field :patient_dob,   date(encounter.patient.dob)
        field :service_dates, date(encounter.service_date)
        field :history,       ref.observations
        field :reasons,       format(ref.reasons, "REFREASONS9611X")
        field :services,      format(ref.services_conducted, "SRV9611X")
        field :code,          ref.code
        field :mins,          ref.minutes
        field :evaluation,    ref.evaluation
        field :recs,          ref.recommendations

        field :evldts, ref.eval_dates
        field :scoremins, ref.scoring_minutes || 0
        field :scrdts, ref.scoring_dates
        field :techmins, ref.tech_scoring_minutes || 0
        field :techdts, ref.tech_scoring_dates
        field :cputests, ref.computer_test_count || 0
        field :cpudts, ref.computer_dates
        field :cpunames, ref.computer_names

        primary_dx = dx_parts.call
        field :d11, primary_dx[0]
        field :d12, primary_dx[1]

        if sec_dx = dx_parts['secondary']
          field :d21, sec_dx[0]
          field :d22, sec_dx[1]
        end

        bool_field :has_wais,      "7".in?(ref.services_conducted.map(&:name))
        bool_field :has_graph,     "10".in?(ref.services_conducted.map(&:name))

        @current_section[:extras] = { wais: ref.wais_extra, graph: ref.graphomotor_extra }
      end

      section :background do
        bg = encounter.background_history

        testing_note_bg_qs.each do |label|
          field label, testing_note_bg_format(label, bg)
          bool_field :has_eval_explanation, bg.eval_needed == "Yes"
          field :evexp, bg.extra.eval_needed
        end
      end

      section :summary do
        st = encounter.functional_status

        field :name, encounter.patient.full_name
        field :dob, date(encounter.patient.dob)
        field :service_dates, date(encounter.service_date)
        field :provider, [ encounter.signer.full_name, encounter.signer.degree ].join(", ")


        score_blk = ->(base, item) do
          st[base] ||= {}
          score = st[base][item] || 0

          bool_field :"#{item}_none", score.zero?
          bool_field :"#{item}_mild", (1..3).include?(score)
          bool_field :"#{item}_moderate", (4..7).include?(score)
          bool_field :"#{item}_severe", score >= 8
        end
        testing_note_impairments.each {|imp| score_blk.call(:impairments, imp) }
        testing_note_interferences.each {|int| score_blk.call(:interferences, int) }

        field :capacity, format(st.independent_capacity, 'CAPFUNC')
        field :cap_comment, st.independent_capacity_comments
        field :duration, format(st.duration, 'STATDUR')
        field :dur_comment, st.duration_comment
        field :comms, st.extra_comments

      end
    end #}}}

    define_generator 'TP' do #{{{
      templates default: 'TP.template.docx', full: 'TP.full.template.docx'

      tp_type = 'TPTYPE'

      section :patient do
        field :last_name,        -> { encounter.patient.last_name }
        field :first_name,       -> {encounter.patient.first_name}
        field :dob,              date(encounter.patient.dob)
        field :gender,           -> { encounter.patient.gender }
        field :facility,         -> { encounter.patient.facility_room }
        field :referrer,         format(encounter.referral.initiator,                                                       'REFINITIATOR')
        field :md_name,          -> {encounter.patient.facility.doctors.find(encounter.referral.md_name.name).try(:name) }
        field :order_date,       date(encounter.referral.order_date)
        field :referral_reasons, format(encounter.referral.reasons,                                                         'REFREASONS')
        field :tp_type,          format(encounter.referral.plan_type,  tp_type)

        if encounter.referral.plan_type.try(:name) == 'discharge'
          field :discharge_reason, format(encounter.referral.discharge_reason, "TPDISREASONS")
        end
      end

      section :diagnosis do
        diag = encounter.diagnosis || Hashie::Mash.new
        primary = Ref::Icd.where(icd: diag.primary.try(:name)).first

        field :primary, primary.to_s
        if((secname=diag.secondary.try(:name)) && (ref=Ref::Icd.where(icd: secname).first))
          field :secondary, ref
        end
        field :prognosis, format(diag.prognosis, 'PROGNOSIS')
        field :med_conditions, diag.medical_conditions
        field :cognitive_screen, format(encounter.functional_status.respondtreatment, 'RESPONDTREATMNT')
        field :score, encounter.functional_status.cognitive_screen, format(encounter.functional_status.respondtreatment_desc, 'RESPNDTREATMNTDESC')
        field :recall, format(encounter.functional_status.recall, "RECALL")

        if tr_com = encounter.functional_status.respondtreatment_comments
          field :treatment_note, tr_com
        end
      end

      tp_interventions = 'TPINTERVENTIONS'

      section :problem do
        pr = encounter.problem
        bg = encounter.background_history

        field :target_symptom, format(pr.major_target_symptom, 'MAJORTARGETSYM')
        field :onset, format(pr.onset, 'PROBLEMONSET')
        field :freq, format(pr.frequency, 'PROBLEMFREQ'), format(pr.intensity, 'PROBLEMINTENSITY')
        field :other, format(pr.other, 'PROBLEMSOTHER')
        field :interventions, format(pr.tp_interventions, tp_interventions)

        meds = bg.onpsychmeds
        meds_content = format(meds, 'ONMEDS')
        if meds.name == 'Y'
          meds_content += " - #{bg.onpsychmeds_medication.to_s}"
          if gdr_opt=bg.gdr_plan
            gdr_content = format(gdr_opt, 'GDRPLAN')
            if gdr_opt.name == 'Y'
              gdr_content << " - #{date(bg.gdr_plan_date)}"
            end
            field :gdr_plan, gdr_content

            if gdr_opt.name.in?(['Y', 'YND'])
              field :gdr_intervention, bg.gdr_plan_interventions
            end
          end
        end
        field :onmeds, meds_content

        if pr.comments_re_goals
          field :goal_note, pr.comments_re_goals
        end
      end

      section :plan do
        pl = encounter.plan
        field :amount_of_service, format(pl.amount_of_service, 'PLANRECOMMENDED')
        if pl.amount_of_service.name == '4'
          field :isnt_recommended, true
          field :not_recommended_reason, format(pl.not_recommended_reason, 'PLANNOTRECOMMENDED')
        else
          field :is_recommended, true
          field :freq, format(pl.frequency, 'PLANFREQUENCY')
          field :duration, format(pl.duration, 'PLANDURATION')

          if pl.other_services
            field :other, format(pl.other_services, 'PLANOTHERSERVICES')
          end
        end
      end

      section :goals do
        if gl = encounter.goals
          %i(increase decrease modify control improve).each do |label|
            if txt = gl.send(label)
              field label, txt
            end
          end
        end
      end

      section :monitoring do
        field :cgii, -> { format(encounter.functional_status.severity, 'CGII') }
        if monitoring_meths = encounter.tp_methods
          mm_data = monitoring_meths[:methods].map do |m|
            if mm = monitoring_meths[m.name]
              {
                label: m.val,
                current: mm.try(:current),
                target: mm.try(:target)
              }
            end
          end.compact
          # FIXME cant use :field here as is
          # lets change that... kthx
          @current_section[:meths] = mm_data unless mm_data.blank?
        end
      end

      section :footer do
        if encounter.signer
          field :dr_name, [encounter.signer.full_name, encounter.signer.degree].join(', ')
        end
        field :service_date, date(encounter.referral.try(:service_date))
      end

    end #}}}

    define_generator 'GBH1' do #{{{
      templates default: 'GBH1.template.docx', full: 'GBH1.full.template.docx'

      tp_type = 'GBH1TYPE'

      section :patient do
        field :last_name,        -> { encounter.patient.last_name }
        field :first_name,       -> {encounter.patient.first_name}
        field :dob,              date(encounter.patient.dob)
        field :gender,           -> { encounter.patient.gender }
        field :facility,         -> { encounter.patient.facility_room }
        field :referrer,         format(encounter.referral.initiator,                                                       'REFINITIATOR')
        field :md_name,          -> {encounter.patient.facility.doctors.find(encounter.referral.md_name.name).try(:name) }
        field :order_date,       date(encounter.referral.order_date)
        field :referral_reasons, format(encounter.referral.reasons,                                                         'REFREASONS')
        field :tp_type,          format(encounter.referral.plan_type,  tp_type)

        if encounter.referral.plan_type.try(:name) == 'discharge'
          field :discharge_reason, format(encounter.referral.discharge_reason, "TPDISREASONS")
        end
      end

      section :diagnosis do
        diag = encounter.diagnosis || Hashie::Mash.new
        primary = Ref::Icd.where(icd: diag.primary.try(:name)).first

        field :primary, primary.to_s
        if((secname=diag.secondary.try(:name)) && (ref=Ref::Icd.where(icd: secname).first))
          field :secondary, ref
        end
        field :prognosis, format(diag.prognosis, 'PROGNOSIS')
        field :med_conditions, diag.medical_conditions
        field :cognitive_screen, format(encounter.functional_status.respondtreatment, 'RESPONDTREATMNT')
        field :score, encounter.functional_status.cognitive_screen, format(encounter.functional_status.respondtreatment_desc, 'RESPNDTREATMNTDESC')
        field :recall, format(encounter.functional_status.recall, "RECALL")

        if tr_com = encounter.functional_status.respondtreatment_comments
          field :treatment_note, tr_com
        end
      end

      tp_interventions = 'GBH1INTERVENTIONS'

      section :problem do
        pr = encounter.problem
        bg = encounter.background_history

        field :target_symptom, format(pr.major_target_symptom, 'MAJORTARGETSYM')
        field :onset, format(pr.onset, 'PROBLEMONSET')
        field :freq, format(pr.frequency, 'PROBLEMFREQ'), format(pr.intensity, 'PROBLEMINTENSITY')
        field :other, format(pr.other, 'PROBLEMSOTHER')
        field :interventions, format(pr.tp_interventions, tp_interventions)

        meds = bg.onpsychmeds
        meds_content = format(meds, 'ONMEDS')
        if meds.name == 'Y'
          meds_content += " - #{bg.onpsychmeds_medication.to_s}"
          if gdr_opt=bg.gdr_plan
            gdr_content = format(gdr_opt, 'GDRPLAN')
            if gdr_opt.name == 'Y'
              gdr_content << " - #{date(bg.gdr_plan_date)}"
            end
            field :gdr_plan, gdr_content

            if gdr_opt.name.in?(['Y', 'YND'])
              field :gdr_intervention, bg.gdr_plan_interventions
            end
          end
        end
        field :onmeds, meds_content

        if pr.comments_re_goals
          field :goal_note, pr.comments_re_goals
        end
      end

      section :plan do
        pl = encounter.plan
        field :amount_of_service, format(pl.amount_of_service, 'PLANRECOMMENDED')
        if pl.amount_of_service.name == '4'
          field :isnt_recommended, true
          field :not_recommended_reason, format(pl.not_recommended_reason, 'PLANNOTRECOMMENDED')
        else
          field :is_recommended, true
          field :freq, format(pl.frequency, 'PLANFREQUENCY')
          field :duration, format(pl.duration, 'PLANDURATION')

          if pl.other_services
            field :other, format(pl.other_services, 'PLANOTHERSERVICES')
          end
        end
      end

      section :goals do
        if gl = encounter.goals
          %i(increase decrease modify control improve staff).each do |label|
            if txt = gl.send(label)
              field label, txt
            end
          end
        end
      end

      section :monitoring do
        field :cgii, -> { format(encounter.functional_status.severity, 'CGII') }
        if monitoring_meths = encounter.tp_methods
          mm_data = monitoring_meths[:methods].map do |m|
            if mm = monitoring_meths[m.name]
              {
                label: m.val,
                current: mm.try(:current),
                target: mm.try(:target)
              }
            end
          end.compact
          # FIXME cant use :field here as is
          # lets change that... kthx
          @current_section[:meths] = mm_data unless mm_data.blank?
        end
      end

      section :footer do
        if encounter.signer
          field :dr_name, [encounter.signer.full_name, encounter.signer.degree].join(', ')
        end
        field :service_date, date(encounter.referral.try(:service_date))


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
        field :start_time, encounter.certification.start_time
        field :end_time, encounter.certification.end_time
        field :prep_time, prep_time
      end

    end #}}}
  end
end

