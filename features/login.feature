Feature: Login
  In order to manage my cloud factory account
  As a CLI user
  I want to setup login information

  Scenario: Logging In
    When I run `cf login` interactively
    And I type "sprout"
    # Then the output should contain "sprout"
    Then the output should contain:
      """
      sprout
      """
    # When I run `cf login` interactively
    # And I type "sprout"
    # Then the output from "cf login" should contain "sprout"
    
    # Then the output should contain "Enter your account name"

    # 
    # 
    # When I run `ruby -e 'puts :simple'`                                         # lib/aruba/cucumber.rb:48
    #     And I run `ruby -e 'puts gets.chomp'` interactively                         # lib/aruba/cucumber.rb:66
    #     And I type "interactive"                                                    # lib/aruba/cucumber.rb:70
    #     Then the output from "ruby -e 'puts :simple'" should contain "simple"       # lib/aruba/cucumber.rb:78
    #     And the output from "ruby -e 'puts gets.chomp'" should not contain "simple"