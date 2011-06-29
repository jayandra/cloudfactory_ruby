Feature: Login
  In order to manage my cloud factory account
  As a CLI user
  I want to setup login information
  
  @slow_process
  Scenario: Logging In
    When I run `cf login` interactively
    And I type "sprout"
    Then the output should contain "API Key saved"
      # """
      # API Key saved
      # """
    # Then the output from "cf login" should contain "API Key saved"