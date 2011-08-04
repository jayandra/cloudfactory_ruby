Feature: Login credentials
  In order to talk with cloud factory
  As a CLI user
  I want to setup login credentials
  
  @announce, @moderate_slow_process
  Scenario: Login
    When I run `cf login` interactively
    And I type "sachin@sproutify.com"
    And I type "secret"
    Then the output should match:
      """
      john@doe.com and secret
      """
    
    # Then the file ".cf_credentials" should contain exactly:
    #   """
    #   ---
    #   :target_url: http://sandbox.staging.cloudfactory.com/api/
    #   :api_version: v1
    #   :api_key: theapikey
    #   
    #   """
    # Then the output should match:
    #   """
    #   
    #   Your cloudfactory credentials saved.
    #   All the best to run your factory on top of CloudFactory.com
    #   
    #   """
