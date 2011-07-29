Feature: Generate Custom Task Forms
  In order to generate custom task forms
  As a CLI user
  I want to generate custom task forms
  
  Scenario: Scaffolding a custom task form but outside of the line directory
    Given a directory named "brandiator"
    When I run `cf form generate --station 1 --labels company,website --fields ceo:string email:email`
    Then the output should contain:
    """
    The current directory is not a valid line directory.
    """

  Scenario: Warn if the given station already has the form created
    Given an empty file named "brandiator/line.yml"
    And a directory named "brandiator/station_2"
    And I cd to "brandiator"
    When I run `cf form generate --station 2 --labels company,website --fields ceo:string email:email`
    Then the output should contain:
      """
      Skipping the form generation because the station_2 already exists with its custom form.
      Use the -f flag to force it to overwrite or check and delete the station_2 folder manually.
      """

  Scenario: Overwrite forcefully if the given station already has the form created
    Given an empty file named "brandiator/line.yml"
    And a directory named "brandiator/station_2"
    And I cd to "brandiator"
    When I run `cf form generate --force --station 2 --labels company,website --fields ceo:string email:email`
    Then the output should contain:
      """
      A new custom task form created in station_2.
      """

  Scenario: Scaffolding a custom task form with all the parameters and valid conditions
    Given an empty file named "brandiator/line.yml"
    And I cd to "brandiator"
    When I run `cf form generate --station 2 --labels company,website --fields ceo:string email:email`
    Then the following files should exist:
      | station_2/form.html |
      | station_2/form.css  |
      | station_2/form.js   |
    And the output should contain:
      """
      A new custom task form created in station_2.
      """