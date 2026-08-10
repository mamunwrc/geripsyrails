class Pat::PatientTPSerializer < ActiveModel::Serializer
  attributes :id, :next_tp, :tp_sessions

  attribute :providers do
    [object.primary_provider.try(:full_name)].compact
  end

  def next_tp
    if tier2?
      DateTime.now
    else
      object.next_tp
    end
  end

  def tp_sessions
    if tier2?
      6 - object.encounters.signed.count
    else
      0
    end
  end

  def tier2?
    object.next_tp and object.next_tp > Pat::Patient::INFINITE_NEXT_TP
  end

  def latest_encounter
    @__enc__ ||= object.encounters.signed.reorder(:signed_on).last
  end

end
