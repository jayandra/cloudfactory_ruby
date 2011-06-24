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
        CF::TaskForm.create({:station => s, :title => "Gem Sinatra App with unit level meta_data implementation", :instruction => "Guess the amount they have earned through bribe in Rupees"}) do |f|
          CF::FormField.new({:form => f, :label => "Amount", :field_type => "SA", :required => "true"})
        end
      end
    end
    
    input_data = "Politician Name, meta_data_name\n"
    # input_data += params[:names]
    
    input_data_array = []
    
    params['names'].each do |data|
      input_data_array << data + "," + data
    end
    
    input_data += input_data_array.join("\n")
    @run = CF::Run.create(line, "2011 Ghotala", input_data)

    haml :run
  end

  get '/result/:id' do
    @run_id = params[:id]
    @got_result = CF::Result.get_result(@run_id)
    
    haml :result
  end
  
  get '/style.css' do
    sass :style, :style => :expanded # overridden
  end

end