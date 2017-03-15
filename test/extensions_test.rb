# encoding: UTF-8
require 'test_helper'

class ExtensionsTest < Test::Unit::TestCase
  def test_force_complete_document
    mmd = 'Some very simple _Markdown_'

    # Don't change anything (default)
    multimarkdown = Multimarkdown.new(mmd)
    assert !multimarkdown.to_html.include?('<html>'), "Found '<html>' tag: '#{multimarkdown.to_html}'"

    # Force complete document
    multimarkdown = Multimarkdown.new(mmd, :complete)
    assert multimarkdown.to_html.include?('<html>'), "Didn't find '<html>' tag: '#{multimarkdown.to_html}'"
  end

  def test_force_snippet_mode
    mmd = "Meta1: Value\nMeta2: Value2\n\nHello!"

    # Don't change anything (default)
    multimarkdown = Multimarkdown.new(mmd)
    assert multimarkdown.to_html.include?('<html>'), "Didn't find '<html>' tag: '#{multimarkdown.to_html}'"

    # Force snippet
    multimarkdown = Multimarkdown.new(mmd, :snippet)
    assert !multimarkdown.to_html.include?('<html>'), "Found '<html>' tag: '#{multimarkdown.to_html}'"
  end

  def test_smart_quotes
    mmd = 'Quotes are "beautiful"'

    # Use smart quotes
    multimarkdown = Multimarkdown.new(mmd, :smart_quotes)
    assert multimarkdown.to_html.include?('&#8220;'), "Didn't find nice quote '&#8220;': '#{multimarkdown.to_html}'"
    assert multimarkdown.to_html.include?('&#8221;'), "Didn't find nice quote '&#8221;': '#{multimarkdown.to_html}'"
    assert !multimarkdown.to_html.include?('&quot;'), "Found quote '&quot;': '#{multimarkdown.to_html}'"

    # Don't use smart quotes (default)
    multimarkdown = Multimarkdown.new(mmd)
    assert_equal '<p>Quotes are &quot;beautiful&quot;</p>', multimarkdown.to_html.strip
  end

  def test_footnotes
    mmd = <<eof
Here is some text containing a footnote.[^somesamplefootnote]

[^somesamplefootnote]: Here is the text of the footnote itself.
eof

    # Use footnotes
    multimarkdown = Multimarkdown.new(mmd, :footnotes)
    assert multimarkdown.to_html.include?('class="footnotes"'),  "Didn't find footnote container: '#{multimarkdown.to_html}'"
    assert multimarkdown.to_html.include?('text of the footnote itself'),  "Didn't find footnote text: '#{multimarkdown.to_html}'"
    assert multimarkdown.to_html.include?('#fnref:1'),  "Didn't find footnote anchor '#fnref:1': '#{multimarkdown.to_html}'"

    multimarkdown = Multimarkdown.new(mmd, :random_footnote_anchor_numbers)
    assert !multimarkdown.to_html.include?('#fnref:1'),  "Found footnote anchor '#fnref:1': '#{multimarkdown.to_html}'"

    # Don't use footnotes (default)
    multimarkdown = Multimarkdown.new(mmd)
    assert !multimarkdown.to_html.include?('class="footnotes"'),  "Found footnote container: '#{multimarkdown.to_html}'"
    assert multimarkdown.to_html.include?('[^somesamplefootnote]'),  "Didn't find footnote markdown text: '#{multimarkdown.to_html}'"
  end

  def test_anchors
    mmd = '# A Heading'

    # Don't change anything (default)
    multimarkdown = Multimarkdown.new(mmd)
    assert multimarkdown.to_html.include?('id="aheading"'),  "Didn't find a tag with 'id=\"aheading\"': '#{multimarkdown.to_html}'"

    # Turn off auto anchors
    multimarkdown = Multimarkdown.new(mmd, :no_anchors)
    assert !multimarkdown.to_html.include?('id="aheading"'),  "Found a tag with 'id=\"aheading\"': '#{multimarkdown.to_html}'"
  end

  def test_filter_styles
    mmd = '<style>p {color: red}</style> <span style="color: blue">It is blue!</span>'

    # Don't change anything (default)
    multimarkdown = Multimarkdown.new(mmd)
    assert multimarkdown.to_html.include?('<style>p {color: red}</style>'), "Didn't find '<style>' tag: '#{multimarkdown.to_html}'"
    assert multimarkdown.to_html.include?('style="color: blue"'), "Didn't inline 'style': '#{multimarkdown.to_html}'"

    # Disbale styles
    multimarkdown = Multimarkdown.new(mmd, :filter_styles)
    assert !multimarkdown.to_html.include?('<style>p {color: red}</style>'), "Found '<style>' tag: '#{multimarkdown.to_html}'"
    # Doesn't work: assert !multimarkdown.to_html.include?('style="color: blue"'), "Found inline 'style': '#{multimarkdown.to_html}'"
  end

  def test_filter_html
    mmd = '<span>Hello from HTML</span>Pure Markdown'

    # Don't change anything (default)
    multimarkdown = Multimarkdown.new(mmd)
    assert multimarkdown.to_html.include?('<span>Hello from HTML</span>'), "Didn't find '<span>' tag: '#{multimarkdown.to_html}'"
    assert multimarkdown.to_html.include?('Pure Markdown<'), "Didn't find Markdown: '#{multimarkdown.to_html}'"

    # Disbale html
    multimarkdown = Multimarkdown.new(mmd, :filter_html)
    assert_equal "<p>Hello from HTMLPure Markdown</p>", multimarkdown.to_html.strip
  end

  # TODO
  # See https://github.com/fletcher/Multimarkdown-4/issues/97
  def disabled_test_markdown_in_html
    mmd = 'Hello <span>[World](http://world.de)</span>!'

    # No Markdown in html supported (default)
    multimarkdown = Multimarkdown.new(mmd)
    assert_equal "<p>Hello <span>_World_</span>!</p>", multimarkdown.to_html.strip

    # now with the extension turned on
    multimarkdown = Multimarkdown.new(mmd, :process_html)
    assert_equal "<p>Hello <span><em>World</em></span>!</p>", multimarkdown.to_html.strip
  end

  def test_no_metadata
    mmd = "A: B\n\nBlabla"

    # Don't do anything (default)
    multimarkdown = Multimarkdown.new(mmd, :no_metadata)
    assert multimarkdown.to_html.include?('A: B'), "Didn't find metadata style text: '#{multimarkdown.to_html}'"
  end

  def test_obfuscation
    mmd = '[Contact me](mailto:mail@example.com)'

    # Don't do anything (default)
    multimarkdown = Multimarkdown.new(mmd)
    assert multimarkdown.to_html.include?('mail@example.com'), "Didn't find email address: '#{multimarkdown.to_html}'"

    # Obfuscate
    multimarkdown = Multimarkdown.new(mmd, :obfuscate_email_addresses)
    assert !multimarkdown.to_html.include?('mail@example.com'), "Found email address: '#{multimarkdown.to_html}'"
  end

  def test_critic_markup
    mmd = 'This is a {++green ++} test.'

    # Don't do anything (default)
    multimarkdown = Multimarkdown.new(mmd)
    assert_equal "<p>This is a {++green ++} test.</p>", multimarkdown.to_html.strip

    # Include changes
    multimarkdown = Multimarkdown.new(mmd, :critic_markup_accept_all)
    assert_equal "<p>This is a green test.</p>", multimarkdown.to_html.strip

    # Ignore changes
    multimarkdown = Multimarkdown.new(mmd, :critic_markup_reject_all)
    assert_equal "<p>This is a test.</p>", multimarkdown.to_html.strip
  end

  def test_escaped_line_breaks
    mmd = <<eof
This is a cool Multimarkdown\\
Feature
eof

    # Don't do anything (default)
    multimarkdown = Multimarkdown.new(mmd)
    assert !multimarkdown.to_html.include?('<br/>'), "Found '<br/>' tag: '#{multimarkdown.to_html}'"

    multimarkdown = Multimarkdown.new(mmd, :escaped_line_breaks)
    assert multimarkdown.to_html.include?('<br/>'), "Didn't find '<br/>' tag: '#{multimarkdown.to_html}'"
  end
end
