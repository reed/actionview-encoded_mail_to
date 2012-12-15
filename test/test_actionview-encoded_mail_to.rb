# encoding: utf-8

require 'minitest/autorun'
require 'rails'
require 'action_pack'
require 'action_view/helpers/capture_helper'
require 'action_view/helpers/url_helper'
require 'action_view/encoded_mail_to/mail_to_with_encoding'

class TestActionViewEncodedMailTo < MiniTest::Unit::TestCase
  include ActionView::Helpers::UrlHelper
  
  def test_initialization
    [:mail_to, :mail_to_with_encoding, :mail_to_without_encoding].each do |method|
      assert_includes ActionView::Helpers::UrlHelper.instance_methods, method
    end
  end
  
  def test_mail_to
    assert_equal %{<a href="mailto:nick@example.com">nick@example.com</a>}, mail_to("nick@example.com")
    assert_equal %{<a href="mailto:nick@example.com">Nick Reed</a>}, mail_to("nick@example.com", "Nick Reed")
    assert_equal %{<a class="admin" href="mailto:nick@example.com">Nick Reed</a>},
                 mail_to("nick@example.com", "Nick Reed", "class" => "admin")
    assert_equal mail_to("nick@example.com", "Nick Reed", "class" => "admin"),
                 mail_to("nick@example.com", "Nick Reed", class: "admin")
  end
  
  def test_mail_to_without_encoding
    assert_equal mail_to("nick@example.com", "Nick Reed"),
                 mail_to_without_encoding("nick@example.com", "Nick Reed")
  end
  
  def test_mail_to_with_javascript
    assert_equal(
      "<script>eval(decodeURIComponent('%76%61%72%20%73%63%72%69%70%74%20%3d%20%64%6f%63%75%6d%65%6e%74%2e%67%65%74%45%6c%65%6d%65%6e%74%73%42%79%54%61%67%4e%61%6d%65%28%27%73%63%72%69%70%74%27%29%3b%73%63%72%69%70%74%20%3d%20%73%63%72%69%70%74%5b%73%63%72%69%70%74%2e%6c%65%6e%67%74%68%20%2d%20%31%5d%3b%76%61%72%20%61%20%3d%20%64%6f%63%75%6d%65%6e%74%2e%63%72%65%61%74%65%45%6c%65%6d%65%6e%74%28%27%61%27%29%3b%61%2e%73%65%74%41%74%74%72%69%62%75%74%65%28%27%68%72%65%66%27%2c%20%27%6d%61%69%6c%74%6f%3a%6d%65%40%64%6f%6d%61%69%6e%2e%63%6f%6d%27%29%3b%61%2e%61%70%70%65%6e%64%43%68%69%6c%64%28%64%6f%63%75%6d%65%6e%74%2e%63%72%65%61%74%65%54%65%78%74%4e%6f%64%65%28%27%4d%79%20%65%6d%61%69%6c%27%29%29%3b%73%63%72%69%70%74%2e%70%61%72%65%6e%74%4e%6f%64%65%2e%69%6e%73%65%72%74%42%65%66%6f%72%65%28%61%2c%73%63%72%69%70%74%29%3b'))</script>",
      mail_to("me@domain.com", "My email", encode: "javascript")
    )
  end
   
  def test_mail_to_with_javascript_unicode
    assert_equal(
      "<script>eval(decodeURIComponent('%76%61%72%20%73%63%72%69%70%74%20%3d%20%64%6f%63%75%6d%65%6e%74%2e%67%65%74%45%6c%65%6d%65%6e%74%73%42%79%54%61%67%4e%61%6d%65%28%27%73%63%72%69%70%74%27%29%3b%73%63%72%69%70%74%20%3d%20%73%63%72%69%70%74%5b%73%63%72%69%70%74%2e%6c%65%6e%67%74%68%20%2d%20%31%5d%3b%76%61%72%20%61%20%3d%20%64%6f%63%75%6d%65%6e%74%2e%63%72%65%61%74%65%45%6c%65%6d%65%6e%74%28%27%61%27%29%3b%61%2e%73%65%74%41%74%74%72%69%62%75%74%65%28%27%68%72%65%66%27%2c%20%27%6d%61%69%6c%74%6f%3a%75%6e%69%63%6f%64%65%40%65%78%61%6d%70%6c%65%2e%63%6f%6d%27%29%3b%61%2e%61%70%70%65%6e%64%43%68%69%6c%64%28%64%6f%63%75%6d%65%6e%74%2e%63%72%65%61%74%65%54%65%78%74%4e%6f%64%65%28%27%c3%ba%6e%69%63%6f%64%65%27%29%29%3b%73%63%72%69%70%74%2e%70%61%72%65%6e%74%4e%6f%64%65%2e%69%6e%73%65%72%74%42%65%66%6f%72%65%28%61%2c%73%63%72%69%70%74%29%3b'))</script>", 
      mail_to("unicode@example.com", "únicode", encode: "javascript")
    )
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
  
    assert_equal(
      %{<script>eval(decodeURIComponent('%76%61%72%20%73%63%72%69%70%74%20%3d%20%64%6f%63%75%6d%65%6e%74%2e%67%65%74%45%6c%65%6d%65%6e%74%73%42%79%54%61%67%4e%61%6d%65%28%27%73%63%72%69%70%74%27%29%3b%73%63%72%69%70%74%20%3d%20%73%63%72%69%70%74%5b%73%63%72%69%70%74%2e%6c%65%6e%67%74%68%20%2d%20%31%5d%3b%76%61%72%20%61%20%3d%20%64%6f%63%75%6d%65%6e%74%2e%63%72%65%61%74%65%45%6c%65%6d%65%6e%74%28%27%61%27%29%3b%61%2e%73%65%74%41%74%74%72%69%62%75%74%65%28%27%68%72%65%66%27%2c%20%27%6d%61%69%6c%74%6f%3a%6d%65%40%64%6f%6d%61%69%6e%2e%63%6f%6d%27%29%3b%61%2e%61%70%70%65%6e%64%43%68%69%6c%64%28%64%6f%63%75%6d%65%6e%74%2e%63%72%65%61%74%65%54%65%78%74%4e%6f%64%65%28%27%4d%79%20%65%6d%61%69%6c%27%29%29%3b%73%63%72%69%70%74%2e%70%61%72%65%6e%74%4e%6f%64%65%2e%69%6e%73%65%72%74%42%65%66%6f%72%65%28%61%2c%73%63%72%69%70%74%29%3b'))</script>},
      mail_to("me@domain.com", "My email", encode: "javascript", replace_at: "(at)", replace_dot: "(dot)")
    )
  
    assert_equal(
      %{<script>eval(decodeURIComponent('%76%61%72%20%73%63%72%69%70%74%20%3d%20%64%6f%63%75%6d%65%6e%74%2e%67%65%74%45%6c%65%6d%65%6e%74%73%42%79%54%61%67%4e%61%6d%65%28%27%73%63%72%69%70%74%27%29%3b%73%63%72%69%70%74%20%3d%20%73%63%72%69%70%74%5b%73%63%72%69%70%74%2e%6c%65%6e%67%74%68%20%2d%20%31%5d%3b%76%61%72%20%61%20%3d%20%64%6f%63%75%6d%65%6e%74%2e%63%72%65%61%74%65%45%6c%65%6d%65%6e%74%28%27%61%27%29%3b%61%2e%73%65%74%41%74%74%72%69%62%75%74%65%28%27%68%72%65%66%27%2c%20%27%6d%61%69%6c%74%6f%3a%6d%65%40%64%6f%6d%61%69%6e%2e%63%6f%6d%27%29%3b%61%2e%61%70%70%65%6e%64%43%68%69%6c%64%28%64%6f%63%75%6d%65%6e%74%2e%63%72%65%61%74%65%54%65%78%74%4e%6f%64%65%28%27%6d%65%28%61%74%29%64%6f%6d%61%69%6e%28%64%6f%74%29%63%6f%6d%27%29%29%3b%73%63%72%69%70%74%2e%70%61%72%65%6e%74%4e%6f%64%65%2e%69%6e%73%65%72%74%42%65%66%6f%72%65%28%61%2c%73%63%72%69%70%74%29%3b'))</script>},
      mail_to("me@domain.com", nil, encode: "javascript", replace_at: "(at)", replace_dot: "(dot)")
    )
  end
  
  def test_mail_to_returns_html_safe_string
    assert mail_to("me@domain.com").html_safe?
    assert mail_to("me@domain.com", "My email", encode: "javascript").html_safe?
    assert mail_to("me@domain.com", "My email", encode: "hex").html_safe?
  end
  
end