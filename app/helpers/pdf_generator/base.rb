module PdfGenerator
  class Base
    include ExportHelpers

    class << self
      def inherited(klass)
        klass.instance_variable_set :@generators, {}
      end

      def generate(collection, opts={})
        new(collection, opts).generate!
      end

      def define_generator(*types, &genblk)
        types.each do |type|
          generators[type] = genblk
        end
      end

      def generators
        @generators
      end
    end

    def initialize(collection, opts={})
      @collection = Array(collection)
      @lookups = Ref::Lookup.all.group_by(&:keyprefix)
      @pdf = Prawn::Document.new
      @type = opts.fetch(:type, 'full')
      @user = opts[:user]
      @opts = opts
    end

    attr_reader :pdf, :encounter, :patient, :lookups

    def generate!
      @collection.each do |item|
        each_page item
      end

      pdf
    end

    private

    def each_page(item)
      raise "#each_page must be defined in subclass"
    end

    def cell(header, *vals)
      val = vals.map {|v|
        Proc === v ? v[] : v
      }.join '; '
      "<b>#{header}</b>: #{val}"
    rescue => e
      Rails.logger.error "ERROR | #{e.class} ~> #{e.message} | \n#{e.backtrace.join("\n")}"
      "<b>#{header}</b>"
    end

    def header(text)
      pdf.text text, align: :center, size: 12
    end

    def section(name, opts={})
      can_run = if(_if = opts[:if])
        !!_if[]
      else
        true
      end
      pdf.text name, size: 10
      return unless can_run
      yield if block_given?
      opts[:own_page] ? pdf.start_new_page : pdf.move_down(4)
    end

    def make_table(rows)
      pdf.table rows, width: pdf.bounds.width, cell_style: {borders: [], padding: 0, size: 8, inline_format: true}
      pdf.move_down 3
    end

  end
end
