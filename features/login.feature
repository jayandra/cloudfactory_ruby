# Disabling this for now coz we won't be using this functionality.
# Might be used in future.
Feature: Login
  In order to talk with cloud factory
  As a CLI user
  I want to setup login credentials
  
  @announce
  Scenario: Logging In
    When I run `cf target --url=http://sandbox.cloudfactory.com`
    Then the file ".cf_credentials" should contain exactly:
      """
      ---
      :target_url: http://sandbox.cloudfactory.com/api/
      :api_version: v1
      
      """
    Then the output should match:
      """
      Your cloudfactory target url is saved as http://sandbox.cloudfactory.com
      All the best to run your factory on top of CloudFactory.com
      """
      
  @announce
  Scenario: Trying to create line without config credentials
    Given an empty file named "brandiator/line.yml"
    And I cd to "brandiator"
    When I run `cf line create`
    Then the output should match:
      """
      You have not set the target url.
      cf target --url=http://sandbox.cloudfactory.com will set it to run on sandbox environment
      """
        
  @announce
  Scenario: Trying to do production run without config credentials
    Given an empty file named "brandiator/line.yml"
    And I cd to "brandiator"
    When I run `cf production start --title my_run_title --input_data input_data.csv`
    Then the output should match:
      """
      You have not set the target url.
      cf target --url=http://sandbox.cloudfactory.com will set it to run on sandbox environment
      """
