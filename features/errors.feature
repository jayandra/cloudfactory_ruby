Feature: CLI Errors
  In order to show the intuitive errors
  As a CLI user
  I want to get clear error messages in CLI
  
  @announce, @too_slow_process
  Scenario: Line without
    Given a file named ".cf_credentials" with:
    """
    ---
    :target_url: http://lvh.me:3000/api/
    :api_version: v1
    :api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6
  
    """
    And a file named "eazytizer/line.yml" with:
    """
    title: eazytizer
    department: NoDept
    
    """
    And I cd to "eazytizer"
    When I run `cf line create`
    Then the output should match:
      """
      Department not found for NoDept
      """
      
  @announce, @too_slow_process
  Scenario: Invalid line input format
    Given a file named ".cf_credentials" with:
    """
    ---
    :target_url: http://lvh.me:3000/api/
    :api_version: v1
    :api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6
  
    """
    And a file named "eazytizer/line.yml" with:
    """
    title: eazytizer
    department: Web Research
    input_formats:
      - name: email
        required: true
        valid_type: noemail
    
    """
    And I cd to "eazytizer"
    When I run `cf line create`
    Then the output should match:
      """
      Valid type cannot be noemail
      """
  
  @announce, @too_slow_process
  Scenario: Invalid station
    Given a file named ".cf_credentials" with:
    """
    ---
    :target_url: http://lvh.me:3000/api/
    :api_version: v1
    :api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6

    """
    And a file named "eazytizer/line.yml" with:
    """
    title: eazytizer
    department: Web Research
    input_formats:
      - name: email
        required: true
        valid_type: email
    stations:
      - station:
          station_index: 1
          station_type: bad-station
    
    """
    And I cd to "eazytizer"
    When I run `cf line create`
    Then the output should match:
      """
      The Station type Bad-station is invalid.
      """

  @announce, @too_slow_process
  Scenario: Invalid worker type
    Given a file named ".cf_credentials" with:
    """
    ---
    :target_url: http://lvh.me:3000/api/
    :api_version: v1
    :api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6

    """
    And a file named "eazytizer/line.yml" with:
    """
    title: eazytizer
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
            worker_type: no-human
            num_workers: 100000
            reward: 5

    """
    And I cd to "eazytizer"
    When I run `cf line create`
    Then the output should match:
      """
      Invalid worker type: no-human.
      """

  @announce, @too_slow_process
  Scenario: Invalid worker number
    Given a file named ".cf_credentials" with:
    """
    ---
    :target_url: http://lvh.me:3000/api/
    :api_version: v1
    :api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6

    """
    And a file named "eazytizer/line.yml" with:
    """
    title: eazytizer
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
            num_workers: 0
            reward: 5

    """
    And I cd to "eazytizer"
    When I run `cf line create`
    Then the output should match:
      """
      Number must be greater than or equal to 1
      """

  # @announce, @too_slow_process
  # Scenario: Invalid Robot worker
  #   Given a file named ".cf_credentials" with:
  #   """
  #   ---
  #   :target_url: http://lvh.me:3000/api/
  #   :api_version: v1
  #   :api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6
  # 
  #   """
  #   And a file named "eazytizer/line.yml" with:
  #   """
  #   title: eazytizer
  #   department: Web Research
  #   input_formats:
  #     - name: email
  #       required: true
  #       valid_type: email
  #   stations:
  #     - station:
  #         station_index: 1
  #         station_type: work
  #         worker:
  #           worker_type: mailer_robot
  #           settings:
  #             to: {{email}}
  #             template_variables:
  #               fb_url: {{fb_url}}
  # 
  #   """
  #   And I cd to "eazytizer"
  #   When I run `cf line create`
  #   Then the output should match:
  #     """
  #     Number must be greater than or equal to 1
  #     """