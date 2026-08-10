module ExportHelpers
  def lookups
    raise 'this must be defined in the including Class'
    Ref::Lookup.all.group_by(&:keyprefix)
  end

  def format(val, prefix, probprefix=nil, **opts)
    return '' unless val
    lookup = lookups[prefix]

    return val.map {|v| format v, prefix}.join("; ") if Array === val
    return val.freetext if val.name == 'FREETEXT'

    label = lookup.find {|l| l.keyname == val.name}.try(:keyvalue)
    matching = opts[:if] ? opts[:if][val] : true

    if val.problems && matching
      probprefix ||= [prefix, 'PROB'].join
      [label, format(val.problems, probprefix)].join " - "
    elsif val.name == '3' && val.hallucinations && matching
      [label, format(val.hallucinations, 'THOUGHTPRHALL')].join " - "
    else
      label.dup
    end
  rescue => e
    Rails.logger.error "ERROR | #{e.class} ~> #{e.message} | \n#{e.backtrace.join("\n")}"
  end

  def localize_time(time)
    return time unless @user
    time.in_time_zone(@user.timezone)
  rescue # User#timezone should always be ok but putting a sanity check here...
    time
  end

  def time(str)
    Time.parse(str.to_s).strftime("%I:%M %p")
  rescue
    str
  end

  def date(str)
    #localize_time(Time.parse(str.to_s)).strftime("%m/%d/%Y")
    Time.parse(str.to_s).strftime("%m/%d/%Y")
  rescue
    str
  end

  def full?
    @type == "full"
  end

  def omit_addendum?
    @type.in? ['no addendum', 'partial']
  end

  def omit_note?
    @type.in? ['no note', 'partial']
  end

  def session_minutes
    cert = encounter.certification
    if cert && cert.start_time && cert.end_time
      t=Time.now
      sthour, stmin = *cert.start_time.split(":")
      ethour, etmin = *cert.end_time.split(":")
      ((t.change(hour: ethour, min: etmin) - t.change(hour: sthour, min: stmin)) / 1.minute).to_i
    else
      0
    end
  end

  def testing_note_bg_format(label, section)
    section ||= Hashie::Mash.new
    section.extra ||= Hashie::Mash.new
    answer, extra =
      case label
      when :info_derived
        (ans = section.info_derived) == "Yes" ? [ans.upcase, section.extra.info_derived ] : ans
      when :eval_needed
        section[label] == "No" ? "Not applicable in this case" : "YES"
      when :more_test
        ans = section.more_test
        section.extra.more_test.blank? ? ans : [ans, section.extra.more_test]
      else
        (ans = section[label]) == "Yes" && !section.extra[label].blank? ?
          [ans, section.extra[label]] :
          ans
      end

    extra.nil? ? answer.upcase : [answer.upcase, extra].join(": ")
  end

  def testing_note_bg_qs
    %i(dementia other prev_testing cog_func emo_func info_derived eval_needed more_test)
  end

  def testing_note_impairments
    %i( intability funcskill langskill attskill reasoning memory memory_long motorspeed probsolve perceptint )
  end

  def testing_note_interferences
    %i( emo org dementia mci )
  end
end

