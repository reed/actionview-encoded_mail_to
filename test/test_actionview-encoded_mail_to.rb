# encoding: utf-8

require 'minitest/autorun'
require 'rails'
require 'action_pack'
require 'action_view'
require 'action_view/encoded_mail_to/mail_to_with_encoding'
ActionView::Helpers::UrlHelper.module_eval do
  prepend ActionView::EncodedMailTo::MailToWithEncoding
end

class TestActionViewEncodedMailTo < MiniTest::Unit::TestCase
  include ActionView::Helpers::UrlHelper

  attr_accessor :output_buffer

  def test_mail_to
    assert_equal %{<a href="mailto:nick@example.com">nick@example.com</a>}, mail_to("nick@example.com")
    assert_equal %{<a href="mailto:nick@example.com">Nick Reed</a>}, mail_to("nick@example.com", "Nick Reed")
    assert_equal %{<a class="admin" href="mailto:nick@example.com">Nick Reed</a>},
                 mail_to("nick@example.com", "Nick Reed", "class" => "admin")
    assert_equal mail_to("nick@example.com", "Nick Reed", "class" => "admin"),
                 mail_to("nick@example.com", "Nick Reed", class: "admin")
  end

  def test_mail_to_with_block
    assert_equal(%{<a href="mailto:nick@example.com">Nick</a>}, mail_to("nick@example.com"){'Nick'})
  end

  def test_mail_to_without_encoding
    assert_equal mail_to("nick@example.com", "Nick Reed"),
                 "<a href=\"mailto:nick@example.com\">Nick Reed</a>"
  end

  def test_mail_to_with_javascript
    assert_match(
      /<script class=\"mail_to-[a-z0-9]*\">eval\(decodeURIComponent\('(%[a-z0-9]{2})*'\)\)<\/script>/,
      mail_to("me@domain.com", "My email", encode: "javascript")
    )
  end

  def test_mail_to_with_javascript_unicode
    assert_match(
      /<script class=\"mail_to-[a-z0-9]*\">eval\(decodeURIComponent\('(%[a-z0-9]{2})*'\)\)<\/script>/,
      mail_to("unicode@example.com", "únicode", encode: "javascript")
    )
  end

  def test_mail_to_with_javascript_and_block
    output = mail_to("me@example.com", nil, encode: "javascript") do
      "<i class='icon-mail'></i>".html_safe
    end
    assert_match(
      /<script class=\"mail_to-[a-z0-9]*\">eval\(decodeURIComponent\('(%[a-z0-9]{2})*'\)\)<\/script>/,
      output
    )
  end

  def test_mail_to_with_javascript_and_block_excluding_name_argument
    output = mail_to("me@example.com", encode: "javascript") do
      "<i class='icon-mail'></i>".html_safe
    end
    assert_match(
      /<script class=\"mail_to-[a-z0-9]*\">eval\(decodeURIComponent\('(%[a-z0-9]{2})*'\)\)<\/script>/,
      output
    )
  end

  def test_multiple_mail_to_with_javascript
    first = mail_to("me@domain.com", "My email", encode: "javascript")
    second = mail_to("me@domain.com", "My email", encode: "javascript")

    assert_match(
      /<script class=\"mail_to-[a-z0-9]*\">eval\(decodeURIComponent\('(%[a-z0-9]{2})*'\)\)<\/script>/,
      first
    )
    assert_match(
      /<script class=\"mail_to-[a-z0-9]*\">eval\(decodeURIComponent\('(%[a-z0-9]{2})*'\)\)<\/script>/,
      second
    )
    refute_equal first, second
  end

  def test_mail_with_options
    assert_equal(
      %{<a href="mailto:me@example.com?cc=ccaddress%40example.com&amp;bcc=bccaddress%40example.com&amp;body=This%20is%20the%20body%20of%20the%20message.&amp;subject=This%20is%20an%20example%20email">My email</a>},
      mail_to("me@example.com", "My email", cc: "ccaddress@example.com", bcc: "bccaddress@example.com", subject: "This is an example email", body: "This is the body of the message.")
    )
  end

  def test_mail_to_with_img
    assert_equal %{<a href="mailto:feedback@example.com"><img src="/feedback.png" /></a>},
                 mail_to('feedback@example.com', '<img src="/feedback.png" />'.html_safe)
  end

  def test_mail_to_with_hex
    assert_equal(
      %{<a href="&#109;&#97;&#105;&#108;&#116;&#111;&#58;%6d%65@%64%6f%6d%61%69%6e.%63%6f%6d">My email</a>},
      mail_to("me@domain.com", "My email", encode: "hex")
    )

    assert_equal(
      %{<a href="&#109;&#97;&#105;&#108;&#116;&#111;&#58;%6d%65@%64%6f%6d%61%69%6e.%63%6f%6d">&#109;&#101;&#64;&#100;&#111;&#109;&#97;&#105;&#110;&#46;&#99;&#111;&#109;</a>},
      mail_to("me@domain.com", nil, encode: "hex")
    )
  end

  def test_mail_to_with_hex_and_block
    output = mail_to("me@example.com", nil, encode: "hex") {
      "<i class='icon-cog'></i> Contact Us".html_safe
    }
    assert_equal(
      %{<a href="&#109;&#97;&#105;&#108;&#116;&#111;&#58;%6d%65@%65%78%61%6d%70%6c%65.%63%6f%6d\"><i class='icon-cog'></i> Contact Us</a>},
      output
    )
  end

  def test_mail_to_with_replace_options
    assert_equal(
      %{<a href="mailto:me@domain.com">me(at)domain(dot)com</a>},
      mail_to("me@domain.com", nil, replace_at: "(at)", replace_dot: "(dot)")
    )

    assert_equal(
      %{<a href="&#109;&#97;&#105;&#108;&#116;&#111;&#58;%6d%65@%64%6f%6d%61%69%6e.%63%6f%6d">&#109;&#101;&#40;&#97;&#116;&#41;&#100;&#111;&#109;&#97;&#105;&#110;&#46;&#99;&#111;&#109;</a>},
      mail_to("me@domain.com", nil, encode: "hex", replace_at: "(at)")
    )

    assert_equal(
      %{<a href="&#109;&#97;&#105;&#108;&#116;&#111;&#58;%6d%65@%64%6f%6d%61%69%6e.%63%6f%6d">My email</a>},
      mail_to("me@domain.com", "My email", encode: "hex", replace_at: "(at)")
    )

    assert_equal(
      %{<a href="&#109;&#97;&#105;&#108;&#116;&#111;&#58;%6d%65@%64%6f%6d%61%69%6e.%63%6f%6d">&#109;&#101;&#40;&#97;&#116;&#41;&#100;&#111;&#109;&#97;&#105;&#110;&#40;&#100;&#111;&#116;&#41;&#99;&#111;&#109;</a>},
      mail_to("me@domain.com", nil, encode: "hex", replace_at: "(at)", replace_dot: "(dot)")
    )

    assert_match(
      /<script class=\"mail_to-[a-z0-9]*\">eval\(decodeURIComponent\('(%[a-z0-9]{2})*'\)\)<\/script>/,
      mail_to("me@domain.com", "My email", encode: "javascript", replace_at: "(at)", replace_dot: "(dot)")
    )

    assert_match(
      /<script class=\"mail_to-[a-z0-9]*\">eval\(decodeURIComponent\('(%[a-z0-9]{2})*'\)\)<\/script>/,
      mail_to("me@domain.com", nil, encode: "javascript", replace_at: "(at)", replace_dot: "(dot)")
    )
  end

  def test_mail_to_returns_html_safe_string
    assert mail_to("me@domain.com").html_safe?
    assert mail_to("me@domain.com", "My email", encode: "javascript").html_safe?
    assert mail_to("me@domain.com", "My email", encode: "hex").html_safe?
  end

end
