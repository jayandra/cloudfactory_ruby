class HumanWorkerApp < Sinatra::Base

  enable :logging

  set :haml, :format => :html5
  set :sass, :style => :compact # default Sass style is :nested

  configure do
    CF.api_key = "f488a62d0307e79ec4f1e6131fa220be47e83d44"
    CF.api_url = "http://manish.lvh.me:3000/api/"
    CF.api_version = "v1"
  end
  
  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
  
  get '/' do
    haml :index
  end

  post '/run' do
    response = RestClient.get 'http://sprout.lvh.me:3000/api/v1/lines.json', {:accept => :json}
    line = CF::Line.create("Nepali Politicians","Survey") do |l|
      CF::Station.create({:line => l, :type => "work"}) do |s|
        CF::InputFormat.new({:station => s, :name => "Politician Name", :required => true, :valid_type => "general"})
        CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
        CF::TaskForm.create({:station => s, :title => "Gem Sinatra App -2", :instruction => "Guess the amount they have earned through bribe in Rupees"}) do |f|
          CF::FormField.new({:form => f, :label => "Amount", :field_type => "SA", :required => "true"})
        end
      end
    end
    
    input_data_array = []
    
    params['names'].each do |data|
      input_data_array << {"Politician Name" => data, "meta_data_name" => data}
    end.join(",")
    @run = CF::Run.create(line, "2011 Ghotala", input_data_array)

    haml :run
  end

  get '/result/:run' do
    run_id = params[:run]
    @got_result = CF::Run.get_final_output(run_id)
    haml :result
  end
  
  get '/style.css' do
    sass :style, :style => :expanded # overridden
  end

end