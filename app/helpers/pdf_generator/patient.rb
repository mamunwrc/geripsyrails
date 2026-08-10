module PdfGenerator
  class Patient < Base
    define_generator :filter do
      header "Patient List"

      header = ["Name", "Dates", "Primary Insurance", "Secondary Insurance", "Facility", "Providers"]

      data = patients.map {|patient|
        providers = patient.providers
        providers = (providers & @opts[:providers]) if @opts[:providers]
        providers = providers.map(&:full_name).join(', ')

        [
          patient.full_name,
          patient.service_dates.map{|d| date(d.to_s)}.join(', '),
          format_insurance(patient),
          format_insurance(patient, 'secondary'),
          patient.facility.name,
          providers,
        ]
      }
      data.unshift header
      make_table data
    end

    attr_reader :patients

    def each_page(patients)
      @patients = patients
      instance_eval(&self.class.generators[:filter])
    end

    def format_insurance(patient, type='primary')
      ins = patient.insurance[type]
      if ins.insurer
        [ins.insurer.name, ins.number].join ': '
      else
        ""
      end
    rescue
      ""
    end
  end
end
