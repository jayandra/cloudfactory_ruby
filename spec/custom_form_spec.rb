require 'spec_helper'

describe CF::CustomForm do
  context "create a stsandard_instruction" do
    it "the plain ruby way" do
      attrs = {:title => "Enter text from a business card image",
        :description => "Describe"}
      html =   '<div id="form-content">
                  <div id="instructions">
                    <ul>
                      <li>Look at the business card properly and fill in asked data.</li>
                      <li>Make sure you enter everything found on business card.</li>
                      <li>Work may be rejected if it is incomplete or mistakes are found.</li>
                    </ul>
                  </div>
                  <div id="image-field-wrapper">
                    <div id = "image-panel" >
                      <img class="card-image" src="{{image_url}}">
                    </div>
                    <div id = "field-panel">
                      Name<br />
                      <input class="input-field first_name" type="text" name="result[first_name]" />
                      <input class="input-field middle_name" type="text" name="result[middle_name]" />
                      <input class="input-field last_name" type="text" name="result[last_name]" /><br />

                      <br />Contact<br />
                      <input class="input-field email" type="text" name="result[email]" placeholder="Email"/>
                      <input class="input-field phone" type="text" name="result[phone]" placeholder="Phone"/>
                      <input class="input-field mobile" type="text" name="result[mobile]" placeholder="Mobile"/><br />

                    </div>
                  </div>
                </div>'
                
        css = 'body {background:#fbfbfb;}
                #instructions{
                  text-align:center;
                }

                #image-field-wrapper{
                  float-left;
                  min-width:1050px;
                  overflow:hidden;
                }

                #field-panel{
                  float:left;
                  padding: 10px 10px 0 10px;
                  min-width:512px;
                  overflow:hidden;
                }

                .input-field{
                  width:150px;
                  margin:4px;
                }'
                
        javascript = '<script src="http://code.jquery.com/jquery-latest.js"></script>
                      <script type="text/javascript" src="http://www.bizcardarmy.com/javascripts/jquery.autocomplete-min.js"></script>
                      <script type="text/javascript">
                        $(document).ready(function(){
                          autocomplete_fields = ["first_name", "middle_name", "last_name", "company", "job_title", "city", "state", "zip"];

                          $.each(autocomplete_fields, function(index, value){
                            var inputField = "input." + value;
                            $(inputField).autocomplete({
                              serviceUrl: "http://www.bizcardarmy.com/cards/return_data_for_autocompletion.json",
                              maxHeight: 400,
                              width: 300,
                              zIndex: 9999,
                              params: { field: value }
                            });
                          });
                        });
                      </script>'

        instruction = CF::CustomForm.new(attrs)

        instruction_1 = CF::CustomForm.create(attrs) do |i|
          i.html = html 
          i.css = css
          i.javascript = javascript
        end

        instruction.title.should eq("Enter text from a business card image")
        instruction.description.should eq("Describe")
        instruction_1.title.should eq("Enter text from a business card image")
        instruction_1.description.should eq("Describe")
      end
    end
  end