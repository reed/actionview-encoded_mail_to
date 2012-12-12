require "rails_encoded_mail_to/version"

module RailsEncodedMailTo
  class Railtie < ::Rails::Railtie
    initializer 'rails_encoded_mail_to' do |app|
      ActiveSupport.on_load(:action_view) do
        require 'rails_encoded_mail_to/mail_to_with_encoding'
      end
    end
  end
end

