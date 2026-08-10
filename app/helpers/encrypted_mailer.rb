module EncryptedMailer
  class << self
    def client
      @client ||= Sendinc::Client.new(ENV['SENDINC_EMAIL'], ENV['SENDINC_PW'])
    end

    def mail(opts={}, &blkopts)
      client.mail(opts, &blkopts)
    end
  end
end

