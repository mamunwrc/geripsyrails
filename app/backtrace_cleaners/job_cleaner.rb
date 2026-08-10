class JobCleaner < ActiveSupport::BacktraceCleaner

  GEM_ROOT_PREFIX_REGEX = %r{^#{Regexp.quote(Gem.dir)}}.freeze
  private_constant(:GEM_ROOT_PREFIX_REGEX)

  PROJECT_ROOT_PREFIX_REGEX = %r{^#{Regexp.quote(Rails.root.to_s)}}.freeze
  private_constant(:PROJECT_ROOT_PREFIX_REGEX)

  # Creates a new cleaner.
  #
  def initialize
    super

    # strip project root prefix
    add_filter { |line| line.gsub(PROJECT_ROOT_PREFIX_REGEX, '') }

    # strip bundled gem root prefix
    add_filter { |line| line.gsub(GEM_ROOT_PREFIX_REGEX, '') }
  end

end
