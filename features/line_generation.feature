Feature: Line manage
  In order to generate a line yaml scaffold
  As a CLI user
  I want to scaffold a line
  
  @slow_process, @announce
  Scenario: Scaffolding a line
    Given a directory named "cf_apps"
    And I cd to "cf_apps"
    When I run `cf line generate brandiator`
    Then a file named "brandiator/line.yml" should exist
    And the following files should exist:
      | brandiator/station_2/form.html |
      | brandiator/station_2/form.css  |
      | brandiator/station_2/form.js   |
      
    And the output should contain:
      """
      A new line named brandiator generated.
      Modify the line.yml file and you can create this line with: cf line create
      """

  @slow_process, @no-clobber
  Scenario: Overwriting with a --force (-f) flag for an existing line
    And I cd to "cf_apps"
    When I run `cf line generate brandiator`
    Then the output should match:
    """
    Skipping brandiator/line.yml because it already exists.
    Use the -f flag to force it to overwrite or check and delete it manually.
    """

  Scenario: No api_key present in the yaml file
    Given a directory named "cf_apps"
    And I cd to "cf_apps"
    And a file named "brandiator/line.yml" with:
      """
      api_key:
      title: brandiator
      department: Survey
      """
    And I cd to "brandiator"
    When I run `cf line create`
    Then the output should match:
      """
      The api_key is missing in the line.yml file
      """