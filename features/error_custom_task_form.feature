Feature: CLI Errors
  In order to show the intuitive errors
  As a CLI user
  I want to get clear error messages in CLI
  
@announce, @too_slow_process
Scenario: Invalid Task Form, without form_title and instruction
  Given a file named ".cf_credentials" with:
  """
  ---
  :target_url: http://lvh.me:3000/api/
  :api_version: v1
  :api_key: 89ceebf739adbf59d34911f4f28b2fa0e1564fb6

  """
  And a file named "dater3/station_2/form.html" with:
  """
  <div id="station_2_instructions" class="station_2 cf_form_instruction">
    <ul>
      <li>Go to the <a href="http://www.facebook.com/search.php?type=users">people search in Facebook</a>.</li>
      <li>Enter the <strong>location</strong> below and hit enter to search</li>
      <li>Now go through and find the hottest date that is <span id="gender">{{gender}}</span> and looks about <span id="age">{{age}}</span> years old.</li>
      <li>After you have searched through many and found the best date, paste their Facebook URL into the field below.</li>
    </ul>
  </div>

  <div id="station_2_form" class="station_2 cf_form_content">
    <div id = "field-panel">
      <p>
        <form>
          <label>Facebook Profile URL of hottest date found</label><br />
          <input id="fb_url" type="text" name="output[fb_url]" data-valid-type="general" /></br>
          <input type="submit" value="submit" />
        </form>
      </p>
    </div>
  </div>
  """
  And a file named "dater3/station_2/form.css" with:
  """
  body { background: #e0e0d8; color: #000; }
  """
  And a file named "dater3/station_2/form.js" with:
  """
  $(document).ready(function() {
      ($('span#gender').text().toLowerCase() == "female") ? "MALE":"FEMALE"
  });
  """

  And a file named "dater3/line.yml" with:
  """
  title: dater3
  department: Web Research
  input_formats:
    - name: email
      required: true
      valid_type: email         # email, url, number, date, phone
    - name: location
      required: true
      valid_type: text          # email, url, number, date, phone
    - name: photo
      required: true
      valid_type: url           # email, url, number, date, phone
  stations:
    - station:
        station_index: 1
        station_type: work      # work, improve, tournament
        worker:
          worker_type: human    # "human" or name of robot (google_translate_robot, etc)
          num_workers: 1
          reward: 5
        task_form:
          form_title: Look at a photo to determine the person's gender and approximate age
          instruction: Click the photo link and then enter the person's gender and approximate age in the form below
          form_fields:
            - label: Gender
              field_type: radio_button
              required: true
              option_values:
                - male
                - female
                - not sure
            - label: Age
              field_type: select_box
              required: true
              option_values:
                - Under 18
                - 18 to 30
                - 30 to 45
                - 45 to 60
                - Over 60
                
    - station:
        station_index: 2
        station_type: tournament
        jury_worker:
          max_judges: 8
          reward: 3
        auto_judge:
          enabled: true
        worker:
          worker_type: human
          num_workers: 3
          reward: 3
        custom_task_form:
          form_title: Title of form
          instruction: 
          html: form.html
          css: form.css
          js: form.js
  """
  And I cd to "dater3"
  When I run `cf line create`
  Then the output should match:
    """
    ["Title can't be blank", "Instruction can't be blank", "Raw html is required"]
    """