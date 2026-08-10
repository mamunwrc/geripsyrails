class Adm::Remit < ApplicationRecord
  audited

  belongs_to :practice, class_name: 'Adm::Practice'
  belongs_to :provider, class_name: 'Usr::Provider', required: false
  belongs_to :remit_batch

  enum status: %i(posted unposted), _prefix: true

  validates :posted_on, presence: true
  validates :status, presence: true
  validates :batch, presence: true
  validates :content, presence: true
  validates :posted_on, uniqueness: { scope: :batch }

  scope :shippable, -> { where(provider_id: Usr::Provider.all.pluck(:id)) }
  scope :unshippable, -> { where(provider_id: nil).or(where.not(provider_id: Usr::Provider.all.pluck(:id))) }
  scope :unshipped, -> { where(shipped: false) }

  def import!
    return self unless String === content
    if posted?
      self.status = :posted
      add_provider!
    elsif unposted_with_payment?
      add_provider!
      self.status = :unposted
    else
      # invalid
      return self
    end

    add_posted_on!
    add_batch!
    if r = Adm::Remit.find_by(posted_on: posted_on, batch: batch)
      r
    else
      save
      self
    end
  end

  def unposted?
    !content.scan(/unposted listing by check number/i).blank?
  end

  def posted?
    !unposted? && !content.scan(/posted listing by check number/i).blank?
  end

  def unposted_with_payment?
    return false unless unposted?

    payment_line = content.scan(/total unposted payments.*/i).first.to_s
    if total = payment_line.split(" ").last
      total.sub("$", "").to_i > 0
    else
      false
    end
  end

  def add_posted_on!
    line = content.split("\r\n").first
    date = line.split('Page').first.sub('IJM', '').strip
    self.posted_on = DateTime.parse(date)
  end

  def add_provider!
    hp_id = content.scan(/P\d\d\.\d+/).first.to_s.split('.').first
    return unless hp_id

    hp_id = hp_id.delete("P").to_i
    pro = practice.providers.where(hp_account: hp_id).first || practice.providers.where(id: hp_id).first
    self.provider_id = pro.id if pro
  end

  def add_batch!
    self.batch = content.scan(/Batch:(.*?)\s/).flatten.first
  end
end
