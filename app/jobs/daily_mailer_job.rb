class DailyMailerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Adm::Practice.all.each do |practice|
      practice.facilities.each.with_index do |facility,idx|
        FacilityMailerJob.set(wait: (30 * idx).seconds).perform_later(facility.id)
      end
    end
  end
end
