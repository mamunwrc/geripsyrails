class Adm::RemitBatch < ApplicationRecord
  audited

  belongs_to :practice
  has_many :remits

  serialize :payload, HashSerializer

  def import!
    (payload.files||[]).map.with_index do |file, idx|
      RemitImport.new(file, idx).tap do |import|
        import.validate!

        if import.valid?
          begin
            remit = remits.build(practice_id: practice_id, content: file[:content])
            remit.import!
            import.add_remit_fields(remit)
            fields = %i(id status provider_id posted_on batch)
            import.remit = Hash[fields.map {|field|
              [field, remit.send(field)]
            }]
          rescue => e
            import.add_error class: e.class, msg: e.message
          end
        end
      end
    end
  end

  def to_params
    (payload.files||[]).inject({}) {|params,f|
      params[:filename] = f['filename'] if f['filename']
      params[:content] = f['content'] if f['content']
      params
    }
  end

  class ImportResponder
    def initialize(practice_id)
      @status = :ok
      @practice_id = practice_id
      @remits = []
    end

    attr_accessor :status, :error, :remits

    def to_response
      {
        status: status,
        error: error,
        practice_id: @practice_id,
        remits: remits.map(&:to_resp)
      }
    end
  end

  class RemitImport
    def initialize(file, idx)
      @status = :ok
      @errors = []
      @file = file
      @idx = idx
    end

    attr_accessor :remit, :key
    attr_reader :errors, :file, :status

    def to_resp
      {
        filename: key,
        status: status,
        errors: errors,
        remit: remit
      }
    end

    def validate!
      unless Hash === file
        add_error 'file in invalid format'
        return
      end

      name_check!
      content_check!
    end

    def valid?
      @status == :ok && @valid_content
    end

    def add_remit_fields(remit)
      self.remit = {
        id: remit.id,
        status: remit.status,
        provider_id: remit.provider_id,
        posted_on: remit.posted_on,
        batch: remit.batch,
      }
    end

    def add_error(err)
      if String === err
        errors << {msg: err}
      else
        errors << err
      end
      @status = :error
    end

    private

    def name_check!
      if file[:filename]
        self.key = file[:filename]
      else
        add_error 'file has no filename'
      end
    end

    def content_check!
      if file[:content].blank?
        add_error 'file contains no content'
        @valid_content = false
      else
        @valid_content = true
      end
    end
  end

end

