require 'spec_helper'

describe CF::CustomTaskForm do
  context "create a standard_instruction" do
    it "in block DSL way" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "custom-task-form/block/create", :record => :new_episodes do
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
                      <input class="input-field first_name" type="text" name="final_output[first_name]" />
                      <input class="input-field middle_name" type="text" name="final_output[middle_name]" />
                      <input class="input-field last_name" type="text" name="final_output[last_name]" /><br />

                      <br />Contact<br />
                      <input class="input-field email" type="text" name="final_output[email]" placeholder="Email"/>
                      <input class="input-field phone" type="text" name="final_output[phone]" placeholder="Phone"/>
                      <input class="input-field mobile" type="text" name="final_output[mobile]" placeholder="Mobile"/><br />

                    </div>
                  </div>
                </div>'
                
        css = '<style>body {background:#fbfbfb;}
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
                }</style>'
                
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

      
        line = CF::Line.create("Digitizecustomform11", "Digitization") do
          CF::InputFormat.new({:line => self, :name => "Name", :required => true, :valid_format => "general"})
          CF::InputFormat.new({:line => self, :name => "Contact", :required => true, :valid_type => "url"})
          CF::Station.create({:line => self, :type => "tournament", :max_judges => 10, :auto_judge => true}) do |s|
            CF::HumanWorker.new({:station => s, :number => 3, :reward => 20})
            CF::CustomTaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe", :raw_html => html, :raw_css => css, :raw_javascript => javascript})
          end
        end
        line.title.should eql("Digitizecustomform11")
        line.department_name.should eql("Digitization")
        line.stations.first.type.should eql("TournamentStation")
        CGI.unescape_html(line.stations.first.form.raw_html).should eql(html)
        CGI.unescape_html(line.stations.first.form.raw_css).should eql(css)
        CGI.unescape_html(line.stations.first.form.raw_javascript).should eql(javascript)
      end
    end
    
    it "in plain ruby way" do
      VCR.use_cassette "custom-task-form/plain/create", :record => :new_episodes do
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
                      <input class="input-field first_name" type="text" name="final_output[first_name]" />
                      <input class="input-field middle_name" type="text" name="final_output[middle_name]" />
                      <input class="input-field last_name" type="text" name="final_output[last_name]" /><br />

                      <br />Contact<br />
                      <input class="input-field email" type="text" name="final_output[email]" placeholder="Email"/>
                      <input class="input-field phone" type="text" name="final_output[phone]" placeholder="Phone"/>
                      <input class="input-field mobile" type="text" name="final_output[mobile]" placeholder="Mobile"/><br />

                    </div>
                  </div>
                </div>'
                
        css = '<style>body {background:#fbfbfb;}
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
                }</style>'
                
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
      
        line = CF::Line.new("Digitizeplainruby111", "Digitization")
        
        input_format_1 = CF::InputFormat.new({:name => "Name", :required => true, :valid_format => "general"})
        input_format_2 = CF::InputFormat.new({:name => "Contact", :required => true, :valid_type => "url"})
        line.input_formats input_format_1
        line.input_formats input_format_2
        
        station = CF::Station.new({:type => "work"})
        line.stations station
        
        worker = CF::HumanWorker.new({:number => 1, :reward => 20})
        line.stations.first.worker = worker

        form = CF::CustomTaskForm.new({:title => "Enter text from a business card image", :instruction => "Describe", :raw_html => html, :raw_css => css, :raw_javascript => javascript})
        line.stations.first.form = form
        line.title.should eql("Digitizeplainruby111")
        line.department_name.should eql("Digitization")
        line.stations.first.type.should eql("WorkStation")
        CGI.unescape_html(line.stations.first.form.raw_html).should eql(html)
        CGI.unescape_html(line.stations.first.form.raw_css).should eql(css)
        CGI.unescape_html(line.stations.first.form.raw_javascript).should eql(javascript)
      end
    end
  end
end