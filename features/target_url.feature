Feature: Target URL
  In order to talk with cloud factory
  As a CLI user
  I want to setup login credentials
  
  Scenario: Setting up staging target uri
    When I run `cf target staging`
    Then the file ".cf_credentials" should contain exactly:
      """
      ---
      :target_url: http://sandbox.staging.cloudfactory.com/api/
      :api_version: v1
      
      """
    Then the output should match:
      """
      
      Your cloudfactory target url is saved as http://sandbox.staging.cloudfactory.com/api/
      Since the target is changed, do cf login to set the valid api key.
      
      """
      
  Scenario: Setting up development target uri
    When I run `cf target development`
    Then the file ".cf_credentials" should contain exactly:
      """
      ---
      :target_url: http://lvh.me:3000/api/
      :api_version: v1

      """
    Then the output should match:
      """

      Your cloudfactory target url is saved as http://lvh.me:3000/api/
      Since the target is changed, do cf login to set the valid api key.

      """

  Scenario: Setting up production target uri
    When I run `cf target production`
    Then the file ".cf_credentials" should contain exactly:
      """
      ---
      :target_url: http://sandbox.cloudfactory.com/api/
      :api_version: v1

      """
    Then the output should match:
      """

      Your cloudfactory target url is saved as http://sandbox.cloudfactory.com/api/
      Since the target is changed, do cf login to set the valid api key.

      """

  Scenario: Show the current target if no param is passed
    Given a file named ".cf_credentials" with:
    """
    ---
    :target_url: http://sandbox.staging.cloudfactory.com/api/
    :api_version: v1
    
    """
    When I run `cf target`
    Then the output should match:
      """
      
      http://sandbox.staging.cloudfactory.com/api/
      
      """
        
  Scenario: Show the message to set the target uri if no param is passed and the .cf_credentials file does not exist
    When I run `cf target`
    Then the output should match:
      """
      
      You have not set the target url yet.
      Set it with: cf target staging or see the help.
      
      """

