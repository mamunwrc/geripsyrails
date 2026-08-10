# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, '/var/log/whenever.log'

ENV.each {|k,v| env(k,v)}

job_type :aptible_rake, 'cd /app && bundle exec rake :task --silent :output'

every 1.day, at: '5:30 am' do
  aptible_rake 'geripsy:daily_mailer'
end

every 1.day, at: '6:00 am' do
  aptible_rake 'geripsy:insurance_notifier'
end

every 1.day, at: '6:10 am' do
  aptible_rake 'geripsy:remit_shipper'
end

every 1.day, at: '6:20 am' do
  aptible_rake 'geripsy:era_sender'
end

every :sunday, at: '3:00 am' do
  aptible_rake 'geripsy:hp_resender'
end

# one hour offset to try to solve issue with tasks not firing
every :sunday, at: '4:00 am' do
  aptible_rake 'geripsy:hp_resender'
end

every :thursday, at: '8:00 am' do
  aptible_rake 'geripsy:hp_resender'
end

# one hour offset to try to solve issue with tasks not firing
every :thursday, at: '9:00 am' do
  aptible_rake 'geripsy:hp_resender'
end
