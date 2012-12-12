# RailsEncodedMailTo

Deprecated support for email address obfuscation within the mail_to helper method.  The options `encode`, `replace_at`, `replace_dot` were removed from Rails in version 4.0.  

## Installation

Add this line to your application's Gemfile:

    gem 'rails_encoded_mail_to'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails_encoded_mail_to

## Usage

Use the `mail_to` helper method just as you did prior to Rails 4.0.

#### Restored options:

 * `:encode` - This key will accept the strings "javascript" or "hex".
   Passing "javascript" will dynamically create and encode the mailto link then
   eval it into the DOM of the page. This method will not show the link on
   the page if the user has JavaScript disabled. Passing "hex" will hex
   encode the email_address before outputting the mailto link.
 * `:replace_at` - When the link name isn't provided, the
   email_address is used for the link label. You can use this option to
   obfuscate the email_address by substituting the @ sign with the string
   given as the value.
 * `:replace_dot` - When the link name isn't provided, the
   email_address is used for the link label. You can use this option to
   obfuscate the email_address by substituting the `.` in the email with the
   string given as the value.

#### Examples

```ruby
mail_to "me@domain.com", "My email", encode: "javascript"
# => <script>eval(decodeURIComponent('%64%6f%63...%27%29%3b'))</script>

mail_to "me@domain.com", "My email", encode: "hex"
# => <a href="mailto:%6d%65@%64%6f%6d%61%69%6e.%63%6f%6d">My email</a>

mail_to "me@domain.com", nil, replace_at: "_at_", replace_dot: "_dot_", class: "email"
# => <a href="mailto:me@domain.com" class="email">me_at_domain_dot_com</a>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
