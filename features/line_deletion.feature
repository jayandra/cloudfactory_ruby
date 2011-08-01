Feature: Deleting a line on CF
  In order to delete a line
  As a CLI user
  I want to delete a line via cli for the line

  @announce, @too_slow_process
  Scenario: Creating then deleting a Line
    Given a file named ".cf_credentials" with:
    """
    ---
    :target_url: http://lvh.me:3000/api/
    :api_version: v1
    """
    And a file named "brandiator/line.yml" with:
    """
    api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6
    title: brandiator-deletion
    description: Describe the line what its purpose is and what it does. You got the idea, right?
    department: Survey
    input_formats:
      - name: company
        required: true
        valid_type: general
    stations:
      - station:
          station_index: 1
          station_type: work
          worker:
            worker_type: human
            num_workers: 2
            reward: 5
          task_form:
            form_title: Enter text from a business card image for TASKFORM
            instruction: Read the business card image and the fill the fields for TASKFORM
            form_fields:
              - label: CEO Name
                field_type: short_answer
                required: true
  """
  And I cd to "brandiator"
  When I run `cf line create`
  Then the output should match:
    """
    Congrats! brandiator-deletion was successfully created.
    """
  When I run `cf line delete`
  Then the output should match:
    """
    The line brandiator-deletion is deleted successfully!
    """