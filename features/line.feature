Feature: Line
  In order to manage lines
  As a CLI
  I want to do CRUD operations on the Line

  Scenario: Creating line
    When I run "cf create Digitize"
    Then the output should contain "Line: Digitize created"
