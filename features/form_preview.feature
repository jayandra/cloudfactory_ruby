Feature: Preview a generated custom form
  In order to preview the generated custom task form
  As a CLI user
  I want to preview the custom task form

  Scenario: Previewing the generated form in the browser with the non-existing station
    Given an empty file named "brandiator/line.yml"
    And I cd to "brandiator"
    When I run `cf form preview --station 2`
    Then the output should contain:
      """
      No form exists for station 2
      Generate the form for station 2 and then preview it.
      """
    
  Scenario: Trying to preview the form for the empty station directory
    Given an empty file named "brandiator/line.yml"
    And a directory named "station_2"
    And I cd to "brandiator"
    When I run `cf form preview --station 2`
    Then the output should contain:
      """
      No form exists for station 2
      Generate the form for station 2 and then preview it.
      """
  @announce
  Scenario: Previewing the generated form in the browser
    Given an empty file named "brandiator/line.yml"
    # And a directory named "station_2"
    And I cd to "brandiator"

    And a file named "station_2/form.html" with:
      """
      <div id="my_form_instructions" class="brandiator cf_form_instruction">
        <ul>
          <li>Sample bullet list of instruction</li>
          <li>Sample bullet list of instruction</li>
          <li>Sample bullet list of instruction</li>
        </ul>
      </div>

      <div id="my_form" class="brandiator cf_form_content">
      <label>{{company}}</label>
      <label>{{website}}</label>

      <div id = "field-panel">
      <p><label>ceo</label><input id="ceo" type="text" name="output[ceo]" data-valid-type="string" /></p>
      <p><label>email</label><input id="email" type="text" name="output[email]" data-valid-type="email" /></p>
      </div>
      </div>
      """
    And a file named "station_2/form.css" with:
      """
      body { background-color: #777; color: #fefefe; }
      """
    And a file named "station_2/form.js" with:
      """
      alert("Hey! If you see me, it means I work.")
      """
  
    When I run `cf form preview --station 2`
    Then a file named "station_2/form_preview.html" should exist
    # And the file ".cf/brandiator/my_form_preview.html" should contain:
    #   """
    #   <!DOCTYPE html>
    #   <html lang="en">
    #     <head>
    #       <title>Form Preview</title>
    #       <link href="my_form.css" media="screen, projection" rel="stylesheet" type="text/css" />
    #       <script src="my_formjs" type="text/javascript"></script>
    #     </head>
    #     <!--[if lt IE 7 ]> <body class="ie6"> <![endif]-->
    #     <!--[if IE 7 ]>    <body class="ie7"> <![endif]-->
    #     <!--[if IE 8 ]>    <body class="ie8"> <![endif]-->
    #     <!--[if IE 9 ]>    <body class="ie9"> <![endif]-->
    #     <!--[if (gt IE 9)|!(IE)]><!--> <body> <!--<![endif]-->
    #     <div id="container">
    #       <div id="my_form_instructions" class="brandiator cf_form_instruction">
    #         <ul>
    #           <li>Sample bullet list of instruction</li>
    #           <li>Sample bullet list of instruction</li>
    #           <li>Sample bullet list of instruction</li>
    #         </ul>
    #       </div>
    # 
    #       <div id="my_form" class="brandiator cf_form_content">
    #       <label>{{company}}</label>
    #       <label>{{website}}</label>
    # 
    #       <div id = "field-panel">
    #       <p><label>ceo</label><input id="ceo" type="text" name="output[ceo]" data-valid-type="string" /></p>
    #       <p><label>email</label><input id="email" type="text" name="output[email]" data-valid-type="email" /></p>
    #       </div>
    #       </div>
    #     </div>
    #   </body>
    #   </html>
    #   """