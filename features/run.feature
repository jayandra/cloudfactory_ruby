Feature: Create a production run on CF
  In order to create a run with the generated line
  As a CLI user
  I want to make a production run

  @announce
  Scenario: Creating a production run without run title
    Given an empty file named "brandiator/line.yml"
    And I cd to "brandiator"
    When I run `cf production start -i input_data.csv`
    Then the output should contain:
      """
      No value provided for required options '--title'
      """

  @announce
  Scenario: Warn about the missing input/run-title.csv input file if not present
    Given an empty file named "brandiator/line.yml"
    And I cd to "brandiator"
    And a directory named "input"
    When I run `cf production start -t my_first-run -i input_data.csv`
    Then the output should contain:
      """
      The input data csv file named input/my-first-run.csv is missing.
      """

  @announce, @too_slow_process
  Scenario: Starting a production
    Given a file named ".cf_credentials" with:
    """
    ---
    :target_url: http://lvh.me:3000/api/
    :api_version: v1
  
    """
    And a file named "brandiator/station_2/form.html" with:
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
    And a file named "brandiator/station_2/form.css" with:
    """
    body { background: #e0e0d8; color: #000; }
    """
    And a file named "brandiator/station_2/form.js" with:
    """
    <script type="text/javascript">
    $(document).ready(function(){
      //do your stuff here
    });
    </script>
    """
    
    And a file named "brandiator/line.yml" with:
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
          station_index: 1
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
          station_index: 2
          station_type: improve
          worker:
            worker_type: human
            num_workers: 1
            reward: 3
          custom_task_form:
            form_title: Enter text from a business card image for CUSTOMTASKFORM
            instruction: Read the business card image and the fill the fields for CUSTOMTASKFORM
            html: form.html
            css: form.css
            js: form.js
    """
    And a file named "brandiator/input/brandiator.csv" with:
    """
    company,website,meta_data_company
    Apple,apple.com,Apple
    """
    And I cd to "brandiator"
    When I run `cf production start --title my_run_title --input_data input_data.csv`
    Then the output should match:
      """
      A run with title my-run-title using the line brandiator created successfully.
      """
