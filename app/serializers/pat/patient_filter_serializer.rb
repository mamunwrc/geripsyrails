class Pat::PatientFilterSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :insurance, :service_dates, :room_num, :primary_provider_id

  def service_dates
    @instance_options[:service_dates][object.id] || []
  end

  attribute :facility_name do
    object.facility.name
  end

  attribute :providers do
    providers = object.providers
    providers = (providers & @instance_options[:providers]) if @instance_options[:providers]
    providers.map(&:full_name).join ', '
  end
end
