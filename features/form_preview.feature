Feature: Preview a generated custom form
  In order to preview the generated custom task form
  As a CLI user
  I want to preview the custom task form

  Scenario: Previewing the generated form in the browser with the non-existing line
    When I run `cf form preview my_form -l no-line`
    Then the output should contain:
      """
      The line with the name no-line don't exist.
      First create a line with this name, generate the form and preview.
      """
    
  Scenario: Previewing the generated form in the browser with existing line but not any form
    Given a directory named ".cf/brandiator"
    When I run `cf form preview my_form -l brandiator`
    Then the output should contain:
      """
      The form named my_form does not exist.
      """
  Scenario: Previewing the generated form in the browser with existing line but without passing form name
    Given a directory named ".cf/brandiator"
    When I run `cf form preview -l brandiator`
    Then the output should contain:
      """
      Title of the form is required to preview.
      """

  Scenario: Previewing the generated form in the browser
    Given a directory named ".cf/brandiator"
    And a file named ".cf/brandiator/my_form.html" with:
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
    And a file named ".cf/brandiator/my_form.css" with:
      """
      body { background-color: #777; color: #fefefe; }
      """
    And a file named ".cf/brandiator/my_form.js" with:
      """
      alert("Hey! If you see me, it means I work.")
      """
  
    When I run `cf form preview my_form -l brandiator`
    Then a file named ".cf/brandiator/my_form_preview.html" should exist
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