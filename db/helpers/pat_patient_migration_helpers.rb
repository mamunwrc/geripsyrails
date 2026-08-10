module PatPatientMigrationHelpers
  class << self
    def fix_dates!
      limit, offset = 1000, 0

      loop do
        processed = 0

        Pat::Patient.select(:id, :dob, :next_tp).offset(offset).limit(limit).each do |pat|
          processed += 1
          Pat::Patient.where(id: pat.id).update(dob: pat.dob.midnight) if pat.dob #this should never happen but just in case...
          Pat::Patient.where(id: pat.id).update(next_tp: pat.next_tp.midnight) if pat.next_tp?
        end

        break if processed.zero?
        offset += limit
      end
    end
  end
end
