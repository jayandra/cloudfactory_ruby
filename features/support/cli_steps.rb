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

When /^I run `([^`]*)` for cf$/ do |cmd|
  Timecop.freeze(Time.now) do
    run_simple(unescape(cmd), false)
  end
end

Given /^a line exists with title "([^"]*)"$/ do |title|
  dir = title
  steps %Q{
      Given a file named "#{dir}/line.yml" with:
      """
      title: #{title}
      department: Web Research
      input_formats:
        - name: email
          required: true
          valid_type: email
      stations:
        - station:
            station_index: 1
            station_type: work
            worker:
              worker_type: human
              num_workers: 1
              reward: 5
            task_form:
              form_title: Enter the email address
              instruction: Do research to get the email address
              form_fields:
                - label: CEO Email
                  field_type: email
                  required: true            
      """
      And I cd to "#{dir}"
      When I run `cf line create`
      Then the output should match:
        """
        Line was successfully created.
        """
      And I cd to "../"
    }
  
end