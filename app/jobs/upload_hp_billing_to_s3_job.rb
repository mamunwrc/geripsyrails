class UploadHpBillingToS3Job < ApplicationJob
  include S3Helpers

  queue_as :default

  def perform(id)
    Enc::Encounter.find(id).tap do |enc|
      shippable_fields do |fields|
        shipped = OpenStruct.new(enc.reload.shipped_hp_billing)

        next unless [fields.filename, fields.xml].all?{|f| shipped[f].present? }
        next unless shipped[fields.s3].blank?

        s3_obj = s3_upload("hp_billing/#{shipped[fields.filename]}", shipped[fields.xml])
        shipped[fields.s3] = s3_obj.to_h
        shipped.delete_field fields.xml
        enc.update! shipped_hp_billing: shipped.to_h
      end
    end
  end

private

  def shippable_fields
    [nil, 'secondary'].each do |prefix|
      fields = OpenStruct.new(Hash[
        %w(filename xml s3).map{|k| [k, [prefix,k].compact*'_'] }
      ])

      yield fields
    end
  end

end
