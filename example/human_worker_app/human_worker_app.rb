class HumanWorkerApp < Sinatra::Base

  enable :logging

  set :haml, :format => :html5
  set :sass, :style => :compact # default Sass style is :nested

  configure do
    CloudFactory.api_key = "f488a62d0307e79ec4f1e6131fa220be47e83d44"
    CloudFactory.api_url = "http://manish.lvh.me:3000/api/"
    CloudFactory.api_version = "v1"
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
    line = CloudFactory::Line.create("Nepali Politicians","Survey") do |l|
      CloudFactory::Station.create({:line => l, :type => "work"}) do |s|
        CloudFactory::InputHeader.new({:station => s, :label => "Politician Name",:field_type => "text_data",:value => "Madhav Kumar Nepal", :required => true, :validation_format => "general"})
        CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20})
        CloudFactory::Form.create({:station => s, :title => "Enter the Amounts they have bribed", :description => "Guess the amount they have earned through bribe in Rupees"}) do |f|
          CloudFactory::FormField.new({:instruction => f, :label => "Amount", :field_type => "SA", :required => "true"})
        end
      end
    end
    
    input_data = "Politician Name\n"
    input_data += params[:names].join("\n")
    # input_data_array = []
    #     params['names'].each do |data|
    #       input_data_array << data + "," + data
    #     end
    #     input_data += input_data_array.join("\n")
    #     debugger
    @run = CloudFactory::Run.create(line, "2011 Ghotala", input_data)

    haml :run
  end

  get '/result/:id' do
    @run_id = params[:id]
    @got_result = CloudFactory::Result.get_result(@run_id)
    
    haml :result
  end
  
  get '/style.css' do
    sass :style, :style => :expanded # overridden
  end

end