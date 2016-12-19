require "action_view/encoded_mail_to/version"

module ActionView
  module EncodedMailTo
    class Engine < ::Rails::Engine
      initializer 'actionview-encoded_mail_to' do |app|
        ActiveSupport.on_load(:action_view) do
          require 'action_view/encoded_mail_to/mail_to_with_encoding'
          ActionView::RoutingUrlFor.send :prepend, ActionView::EncodedMailTo::MailToWithEncoding
        end
      end
    end
  end
end

