Feature: Target URL
  In order to talk with cloud factory
  As a CLI user
  I want to setup login credentials
  
  @announce
  Scenario: Logging In
    When I run `cf target --url=http://sandbox.staging.cloudfactory.com`
    Then the file ".cf_credentials" should contain exactly:
      """
      ---
      :target_url: http://sandbox.staging.cloudfactory.com/api/
      :api_version: v1
      
      """
    Then the output should match:
      """
      
      Your cloudfactory target url is saved as http://sandbox.staging.cloudfactory.com
      All the best to run your factory on top of CloudFactory.com
      
      """
      
  @announce
  Scenario: Show the current target if no --url option is passed
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
        
  @announce
  Scenario: Show the message to set the target uri if no --url option is passed and the .cf_credentials file does not exist
    When I run `cf target`
    Then the output should match:
      """
      
      You have not set the target url yet.
      Set the target uri with: cf target --url=http://sandbox.staging.cloudfactory.com
      
      """

