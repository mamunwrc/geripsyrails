class MonthlyBookkeepingJob < ApplicationJob
  queue_as :default

  BILLING_FEE_PER_FTE = 1000.00

  BILLING_TIME_ZONE = ActiveSupport::TimeZone['Eastern Time (US & Canada)']

  # 35 clinical hours per week = 145.83 hours per month
  FULL_TIME_HOURS = 145.83

  # management fee for a full 145.83 hours per month
  MAX_MANAGEMENT_FEE = 4500.00

  # management fee for a full 145.83 hours per month for LCSW providers
  LCSW_MAX_MANAGEMENT_FEE = 3750.00

  def perform(*args)
    return unless ENV['ADMIN_EMAIL']

    require 'csv'

    today =
      if ds=args.first
        Date.parse(ds)
      else
        1.month.ago.to_date
      end
    admin = Usr::Admin.first

    csv = CSV.generate do |c|
      c << [today.strftime("%B, %Y"), "#{FULL_TIME_HOURS}=FT"]
      c << ['Provider', 'CPT', 'Sessions', 'Fee', 'Total', 'Minutes', 'Total hours', 'FTE', 'Fee']

      total_ftes = 0
      admin.providers.each do |provider|
        results = admin.bookkeeping({
          provider_ids: [provider.id],
          from: today.beginning_of_month.in_time_zone(BILLING_TIME_ZONE).to_s,
          to: today.end_of_month.in_time_zone(BILLING_TIME_ZONE).end_of_day.to_s,
          use_raw_date: true,
        })

        total = 0
        total_minutes = 0
        results.each do |cpt, result|
          minutes = result[:count] * billable_hours(cpt)
          c << [provider.full_name, cpt, result[:count], "$#{result[:rate] * 0.01}", minutes]
          total += result[:rate]
          total_minutes += minutes
        end
        total_hours = total_minutes / 60.0
        full_time_equivalent = total_hours / FULL_TIME_HOURS
        total_ftes += [full_time_equivalent, 1.0].min

        max_management_fee = (provider.degree == 'LCSW' ? LCSW_MAX_MANAGEMENT_FEE : MAX_MANAGEMENT_FEE)
        management_fee = [(full_time_equivalent * max_management_fee), max_management_fee].min
        c << [provider.full_name, nil, nil, nil, format_dollars(total * 0.01), format_decimal(total_minutes), format_decimal(total_hours), full_time_equivalent, management_fee]
        c << []
      end
      c << []
      c << ['Billing fee']
      billing_fee = total_ftes * BILLING_FEE_PER_FTE
      c << [format_dollars(billing_fee)]
    end

    EncryptedMailer.mail({
      to: ENV['ADMIN_EMAIL'],
      subject: [today.strftime("%B, %Y"), 'Bookkeeping'].join(' '),
      body: 'attached',
      attachments: [{
        string: csv,
        filename: [today.strftime("%B").downcase, 'bookkeeping'].join('-'),
        filetype: '.csv'
      }]
    })
  end

  private

  def billable_hours(cpt)
    case cpt
    when '90791', '90837', '96130', '96121'
      60
    when '90834', '90846', '90847', '90853'
      45
    when '90832'
      30
    when '96136', '96137'
      20
    when 'GBH1', 'G0323'
      15
    else
      0
    end
  end

  def format_dollars(amount)
    format('$%.2f', amount)
  end

  def format_decimal(amount)
    format('%.2f', amount)
  end

end
