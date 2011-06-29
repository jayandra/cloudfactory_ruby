Feature: Line manage
  In order to generate a line yaml scaffold
  As a CLI user
  I want to generate a line scaffold
  
  @slow_process
  Scenario: Scaffolding a line
    When I run `cf line generate brandiator`
    Then a file named ".cf/brandiator/brandiator.yml" should exist
    And the output should contain:
      """
      A new line named brandiator created.
      """

  @slow_process, @no-clobber
  Scenario: Overwriting with a --force (-f) flag for an existing line
    When I run `cf line generate brandiator`
    Then the output should match:
    """
    Skipping .*.cf/brandiator/brandiator.yml because it already exists.
    Use the -f flag to force it to overwrite or check and delete it manually.
    """
