Feature: Create a production run on CF
  In order to create a run with the generated line
  As a CLI user
  I want to make a production run

  Scenario: Creating a production run without run title
    Given a file named ".cf/brandiator/input_data.csv" with:
    """
    Company,Website,meta_data_company
    Apple,apple.com,Apple
    """
    When I run `cf run create -l no-line -i input_data.csv`
    Then the output should contain:
      """
      The Run title is required so that you can trace the results using this title.
      """

  Scenario: Creating a production run without existing line
    Given a file named ".cf/brandiator/input_data.csv" with:
    """
    Company,Website,meta_data_company
    Apple,apple.com,Apple
    """
    When I run `cf run create my_run_title -l no-line -i input_data.csv`
    Then the output should contain:
      """
      The line with the name no-line doesn't exist.
      First create a line with this name and make a production run.
      """

  Scenario: Creating a production run existing line folder but missing yml file
    Given a directory named ".cf/brandiator"
    And an empty file named ".cf/brandiator/input_data.csv"
    When I run `cf run create my_run_title -l no-line -i input_data.csv`
    Then the output should contain:
      """
      The line with the name no-line doesn't exist.
      First create a line with this name and make a production run.
      """

  @too_slow_process
  Scenario: Creating a production run
    Given a file named ".cf/brandiator/html_form.html" with:
    """
    <div id="my_form_instructions" class="brandiator cf_form_instruction">
      <ul>
        <li>Sample bullet list of instruction</li>
      </ul>
    </div>
    <div id="my_form" class="brandiator cf_form_content">
    <label>{{company}}</label>
    <label>{{website}}</label>
    <div id = "field-panel">
    <p><label>ceo</label><input id="ceo" type="text" name="output[ceo]" data-valid-type="string" /></p>
    <p><label>email</label><input id="email" type="text" name="output[email]" data-valid-type="email" /></p>
    </div>
    </div>
    """
    And a file named ".cf/brandiator/css_file.css" with:
    """
    body { background: #e0e0d8; color: #000; }
    """
    And a file named ".cf/brandiator/js_file.js" with:
    """
    <script type="text/javascript">
    $(document).ready(function(){
      //do your stuff here
    });
    </script>
    """
    
    And a file named ".cf/brandiator/brandiator.yml" with:
    """
    api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6
    title: brandiator
    description: Describe the line what its purpose is and what it does. You got the idea, right?
    department: Survey

    input_formats:
      - input_format:
          name: company
          required: true
          valid_type: general
      - input_format:
          name: website
          required: false
          valid_type: url

    stations:
      - station:
          station_type: work
          worker:
            worker_type: human
            num_workers: 2
            reward: 5
          task_form:
            form_title: Enter text from a business card image for TASKFORM
            instruction: Read the business card image and the fill the fields for TASKFORM
            form_fields:
              - form_field:
                  label: CEO Name
                  field_type: short_answer
                  required: true
              - form_field:
                  label: CEO Email
                  field_type: email
                  required: true
      - station:
          station_type: improve
          worker:
            worker_type: human
            num_workers: 1
            reward: 3
          custom_task_form:
            form_title: Enter text from a business card image for CUSTOMTASKFORM
            instruction: Read the business card image and the fill the fields for CUSTOMTASKFORM
            html: html_form.html
            css: css_file.css
            js: js_file.js
    """
    And a file named ".cf/brandiator/input_data.csv" with:
    """
    company,website,meta_data_company
    Apple,apple.com,Apple
    """
    When I run `cf run create my_run_title -l brandiator --input_data input_data.csv`
    Then the output should match:
      """
      A run with title my_run_title using the line brandiator created successfully.
      """
