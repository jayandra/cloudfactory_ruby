Then /^I should see "([^"]*)"$/ do |expected|
  assert_partial_output(expected, all_output)
end

When /^I type "([^"]*)" and press Enter$/ do |text|
  type(text)
end

Then /^I debug$/ do
  breakpoint
  0
end

Then /^the file "([^"]*)" should contain:$/ do |file, partial_content|
  check_file_content(file, partial_content, true)
end