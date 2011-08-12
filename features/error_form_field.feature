Feature: CLI Errors
  In order to show the intuitive errors
  As a CLI user
  I want to get clear error messages in CLI
  
@announce, @too_slow_process
Scenario: Invalid Form Field
  Given a file named ".cf_credentials" with:
  """
  ---
  :target_url: http://lvh.me:3000/api/
  :api_version: v1
  :api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6

  """
  And a file named "dater/line.yml" with:
  """
  title: dater
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
          form_title: Look at a photo to determine the person's gender and approximate age
          instruction: Click the photo link and then enter the person's gender and approximate age in the form below
          form_fields:
            - label: Gender
              field_type: INVALID_TYPE
              required: true
              option_values:
                - male
                - female
                - not sure
            - label: Age
              field_type: SB
              required: true
              option_values:
                - Under 18
                - 18 to 30
                - 30 to 45
                - 45 to 60
                - Over 60
  """
  And I cd to "dater"
  When I run `cf line create`
  Then the output should match:
    """
    Field type cannot be INVALID_TYPE
    """