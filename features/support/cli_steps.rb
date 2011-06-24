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