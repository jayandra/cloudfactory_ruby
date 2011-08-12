Feature: CLI Errors
  In order to show the intuitive errors
  As a CLI user
  I want to get clear error messages in CLI
  
@announce, @too_slow_process
Scenario: Invalid Task Form, without form_title and instruction
  Given a file named ".cf_credentials" with:
  """
  ---
  :target_url: http://lvh.me:3000/api/
  :api_version: v1
  :api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6

  """
  And a file named "dater2/line.yml" with:
  """
  title: dater2
  department: Web Research
  input_formats:
    - name: email
      required: true
      valid_type: email         # email, url, number, date, phone
    - name: location
      required: true
      valid_type: text          # email, url, number, date, phone
    - name: photo
      required: true
      valid_type: url           # email, url, number, date, phone
  stations:
    - station:
        station_index: 1
        station_type: work      # work, improve, tournament
        worker:
          worker_type: human    # "human" or name of robot (google_translate_robot, etc)
          num_workers: 1
          reward: 5
        task_form:
          form_title: 
          instruction: 
          form_fields:
            - label: Gender
              field_type: radio_button
              required: true
              option_values:
                - male
                - female
                - not sure
            - label: Age
              field_type: select_box
              required: true
              option_values:
                - Under 18
                - 18 to 30
                - 30 to 45
                - 45 to 60
                - Over 60
  """
  And I cd to "dater2"
  When I run `cf line create`
  Then the output should match:
    """
    ["Title can't be blank", "Instruction can't be blank"]
    """