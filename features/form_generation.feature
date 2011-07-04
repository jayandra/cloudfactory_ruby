Feature: Generate Custom Task Forms
  In order to generate custom task forms
  As a CLI user
  I want to generate custom task forms
  
  Scenario: Scaffolding a custom task form without the form title
    When I run `cf form generate --line brandiator --labels company,website --fields ceo:string email:email`
    Then the output should contain:
      """
      Title for the form is required.
      """

  Scenario: Scaffolding a custom task form but with no line created
    When I run `cf form generate my_form --line brandiator --labels company,website --fields ceo:string email:email`
    Then the output should contain:
      """
      The line with the name brandiator don't exist.
      First create a line with this name and generate the form.
      """

  Scenario: Warn if the form with the same name already exists
    Given an empty file named ".cf/brandiator/brandiator.yml"
    And an empty file named ".cf/brandiator/my_form.html"
    When I run `cf form generate my_form --line brandiator --labels company,website --fields ceo:string email:email`
    Then the output should contain:
      """
      Skipping the form because it already exists.
      Use the -f flag to force it to overwrite or check and delete it manually.
      """
  Scenario: Scaffolding a custom task form with all the parameters and valid conditions
    Given an empty file named ".cf/brandiator/brandiator.yml"
    When I run `cf form generate my_form --line brandiator --labels company,website --fields ceo:string email:email`
    Then the following files should exist:
      | .cf/brandiator/my_form.html |
      | .cf/brandiator/my_form.css  |
      | .cf/brandiator/my_form.js   |
    And the output should contain:
      """
      A new custom task form named my_form created.
      """