Feature: Deleting a line on CF
  In order to delete a line
  As a CLI user
  I want to delete a line via cli for the line

  Background:
    Given a file named ".cf_credentials" with:
    """
    ---
    :target_url: http://lvh.me:3000/api/
    :api_version: v1
    :api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6

    """
  
  @announce, @too_slow_process
  Scenario: Deleting an existing a line being inside the line directory
    Given a line exists with title "brandiator"
    And I cd to "brandiator"
    When I run `cf line delete`
    Then the output should match:
      """
      The line brandiator deleted successfully!
      """
      
  @announce, @too_slow_process
  Scenario: Deleting an existing from anywhere
    Given a line exists with title "easytizer"
    When I run `cf line delete -l=easytizer`
    Then the output should match:
      """
      The line easytizer deleted successfully!
      """