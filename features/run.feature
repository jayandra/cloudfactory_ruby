Feature: Create a production run on CF
  In order to create a run with the generated line
  As a CLI user
  I want to make a production run

  Background:
    Given a file named ".cf_credentials" with:
    """
    ---
    :target_url: http://lvh.me:3000/api/
    :api_version: v1
    :api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6
  
    """
  @announce, @moderate_slow_process
  Scenario: Creating a production run without run title should be created using the "line-title-11aug10-hhmmss"
    Given a line exists with title "brandiator"
    And a file named "brandiator/input/input-data.csv" with:
    """
    company,website,meta_data_company
    Apple,apple.com,Apple
    """
    And I cd to "brandiator"
    When I run `cf production start` for cf
    Then the output should contain:
      """
      A run with title brandiator- using the line brandiator was successfully created.
      """

  # @announce
  # Scenario: Warn about the missing input/input_data.csv input file if not present
  #   Given a file named "brandiator/line.yml" with:
  #   """
  #   api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6
  #   title: brandiator
  #   """
  #   And I cd to "brandiator"
  #   And a directory named "input"
  #   When I run `cf production start my_first-run -i input_data.csv`
  #   Then the output should contain:
  #     """
  #     The input data csv file named input/input_data.csv is missing.
  #     """
  # 
  # @announce
  # Scenario: Warn about the missing input/run-title.csv input file if not present when -i optional value is not passed
  #   Given a file named "brandiator/line.yml" with:
  #   """
  #   api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6
  #   title: brandiator
  #   """
  #   And I cd to "brandiator"
  #   And a directory named "input"
  #   When I run `cf production start my_first-run`
  #   Then the output should contain:
  #     """
  #     The input data csv file named input/my-first-run.csv is missing.
  #     """
  # 
  # @announce, @too_slow_process
  # Scenario: Starting a production
  #   Given a file named ".cf_credentials" with:
  #   """
  #   ---
  #   :target_url: http://lvh.me:3000/api/
  #   :api_version: v1
  # 
  #   """
  #   And a file named "brandiator/station_2/form.html" with:
  #   """
  #   <form>
  #   <div id="my_form_instructions" class="brandiator cf_form_instruction">
  #     <ul>
  #       <li>Sample bullet list of instruction</li>
  #     </ul>
  #   </div>
  #   <div id="my_form" class="brandiator cf_form_content">
  #   <label>{{company}}</label>
  #   <label>{{website}}</label>
  #   <div id = "field-panel">
  #   <p><label>ceo</label><input id="ceo" type="text" name="output[ceo]" data-valid-type="string" /></p>
  #   <p><label>email</label><input id="email" type="text" name="output[email]" data-valid-type="email" /></p>
  #   </div>
  #   </div>
  #   </form>
  #   """
  #   And a file named "brandiator/station_2/form.css" with:
  #   """
  #   body { background: #e0e0d8; color: #000; }
  #   """
  #   And a file named "brandiator/station_2/form.js" with:
  #   """
  #   $(document).ready(function(){
  #     //do your stuff here
  #   });
  #   """
  #   
  #   And a file named "brandiator/line.yml" with:
  #   """
  #   api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6
  #   title: brandiator
  #   description: Describe the line what its purpose is and what it does. You got the idea, right?
  #   department: Survey
  # 
  #   input_formats:
  #     - name: company
  #       required: true
  #       valid_type: general
  #     - name: website
  #       required: false
  #       valid_type: url
  # 
  #   stations:
  #     - station:
  #         station_index: 1
  #         station_type: work
  #         worker:
  #           worker_type: human
  #           num_workers: 2
  #           reward: 5
  #         task_form:
  #           form_title: Enter text from a business card image for TASKFORM
  #           instruction: Read the business card image and the fill the fields for TASKFORM
  #           form_fields:
  #             - label: CEO Name
  #               field_type: short_answer
  #               required: true
  #             - label: CEO Email
  #               field_type: email
  #               required: true
  #     - station:
  #         station_index: 2
  #         station_type: work
  #         worker:
  #           worker_type: human
  #           num_workers: 1
  #           reward: 3
  #         custom_task_form:
  #           form_title: Enter text from a business card image for CUSTOMTASKFORM
  #           instruction: Read the business card image and the fill the fields for CUSTOMTASKFORM
  #           html: form.html
  #           css: form.css
  #           js: form.js
  #   """
  #   And a file named "brandiator/input/my-run-title.csv" with:
  #   """
  #   company,website,meta_data_company
  #   Apple,apple.com,Apple
  #   """
  #   And I cd to "brandiator"
  #   When I run `cf production start my_run_title`
  #   Then the output should match:
  #     """
  #     A run with title my-run-title using the line brandiator was successfully created.
  #     """
