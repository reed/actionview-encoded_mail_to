# encoding: utf-8

module EncodedMailTo
  module ::ActionView
    module Helpers
      module UrlHelper
        # Creates a mailto link tag to the specified +email_address+, which is
        # also used as the name of the link unless +name+ is specified. Additional
        # HTML attributes for the link can be passed in +html_options+.
        #
        # +mail_to+ has several methods for hindering email harvesters and customizing
        # the email itself by passing special keys to +html_options+.
        #
        # ==== Options
        # * <tt>:encode</tt> - This key will accept the strings "javascript" or "hex".
        #   Passing "javascript" will dynamically create and encode the mailto link then
        #   eval it into the DOM of the page. This method will not show the link on
        #   the page if the user has JavaScript disabled. Passing "hex" will hex
        #   encode the +email_address+ before outputting the mailto link.
        # * <tt>:replace_at</tt> - When the link +name+ isn't provided, the
        #   +email_address+ is used for the link label. You can use this option to
        #   obfuscate the +email_address+ by substituting the @ sign with the string
        #   given as the value.
        # * <tt>:replace_dot</tt> - When the link +name+ isn't provided, the
        #   +email_address+ is used for the link label. You can use this option to
        #   obfuscate the +email_address+ by substituting the . in the email with the
        #   string given as the value.
        # * <tt>:subject</tt> - Preset the subject line of the email.
        # * <tt>:body</tt> - Preset the body of the email.
        # * <tt>:cc</tt> - Carbon Copy additional recipients on the email.
        # * <tt>:bcc</tt> - Blind Carbon Copy additional recipients on the email.
        #
        # ==== Examples
        #   mail_to "me@domain.com"
        #   # => <a href="mailto:me@domain.com">me@domain.com</a>
        #
        #   mail_to "me@domain.com", "My email", encode: "javascript"
        #   # => <script>eval(decodeURIComponent('%64%6f%63...%27%29%3b'))</script>
        #
        #   mail_to "me@domain.com", "My email", encode: "hex"
        #   # => <a href="mailto:%6d%65@%64%6f%6d%61%69%6e.%63%6f%6d">My email</a>
        #
        #   mail_to "me@domain.com", nil, replace_at: "_at_", replace_dot: "_dot_", class: "email"
        #   # => <a href="mailto:me@domain.com" class="email">me_at_domain_dot_com</a>
        #
        #   mail_to "me@domain.com", "My email", cc: "ccaddress@domain.com",
        #            subject: "This is an example email"
        #   # => <a href="mailto:me@domain.com?cc=ccaddress@domain.com&subject=This%20is%20an%20example%20email">My email</a>
        def mail_to_with_encoding(email_address, name = nil, html_options = {}, &block)
          html_options.stringify_keys!
          if %w[encode replace_at replace_dot].none?{ |option| html_options.has_key? option }
            mail_to_without_encoding email_address, name, html_options, &block
          else
            _mail_to_with_encoding email_address, name, html_options, &block
          end
        end
        alias_method_chain :mail_to, :encoding
        
        private
        
          def _mail_to_with_encoding(email_address, name = nil, html_options = {}, &block)
            email_address = ERB::Util.html_escape(email_address)
            
            encode = html_options.delete("encode").to_s
                    
            extras = %w{ cc bcc body subject }.map { |item|
              option = html_options.delete(item) || next
              "#{item}=#{Rack::Utils.escape_path(option)}"
            }.compact
            extras = extras.empty? ? '' : '?' + ERB::Util.html_escape(extras.join('&'))
                    
            email_address_obfuscated = email_address.to_str
            email_address_obfuscated.gsub!(/@/, html_options.delete("replace_at")) if html_options.key?("replace_at")
            email_address_obfuscated.gsub!(/\./, html_options.delete("replace_dot")) if html_options.key?("replace_dot")
          
            case encode
            when "javascript"
              string = ''
              set_attributes = ''
              html_options.merge("href" => "mailto:#{email_address}#{extras}".html_safe).each_pair do |name,value|
                set_attributes += "a.setAttribute('#{name}', '#{value}');"
              end
              script_id = rand(36**8).to_s(36)
              if block_given?
                block_content = capture(&block).gsub('\'', %q(\\\')).gsub(/\n/, ' ')
                link_content = "a.innerHTML='#{block_content}';"
              else
                link_content = "a.appendChild(document.createTextNode('#{name || email_address_obfuscated.html_safe}'));"
              end
              create_link = "var script = document.getElementById('mail_to-#{script_id}');" +
                            "var a = document.createElement('a');" +
                            "#{set_attributes}" + 
                            link_content +
                            "script.parentNode.insertBefore(a,script);"
              create_link.each_byte do |c|
                string << sprintf("%%%x", c)
              end
              "<script id=\"mail_to-#{script_id}\">eval(decodeURIComponent('#{string}'))</script>".html_safe
            when "hex"
              email_address_encoded = email_address_obfuscated.unpack('C*').map {|c|
                sprintf("&#%d;", c)
              }.join
                    
              string = 'mailto:'.unpack('C*').map { |c|
                sprintf("&#%d;", c)
              }.join + email_address.unpack('C*').map { |c|
                char = c.chr
                char =~ /\w/ ? sprintf("%%%x", c) : char
              }.join
                    
              content_tag "a", name || email_address_encoded.html_safe, html_options.merge("href" => "#{string}#{extras}".html_safe), &block
            else
              content_tag "a", name || email_address_obfuscated.html_safe, html_options.merge("href" => "mailto:#{email_address}#{extras}".html_safe), &block
            end
          end
      end
    end
  end
end