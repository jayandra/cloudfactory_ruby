class HumanWorkerApp < Sinatra::Base

  set :haml, :format => :html5
  set :sass, :style => :compact # default Sass style is :nested

  configure do
    CloudFactory.api_key = "133fcabc51e35903e616c25aace7ffccc819c8f0"
    CloudFactory.api_url = "sprout.lvh.me:3000/api/"
    CloudFactory.api_version = "v1"
  end

  get '/' do
    haml :index

  end

  get '/run' do
    # CloudFactory.api_url = "sprout.lvh.me:3000/api/"
    response = RestClient.get 'http://sprout.lvh.me:3000/api/v1/lines.json', {:accept => :json}
    # @categories = CloudFactory::Category.all
# Tournament  
    line = CloudFactory::Line.create("Nepali Politicians","Survey") do |l|
      CloudFactory::Station.create({:line => l, :type => "tournament"}) do |s|
        CloudFactory::InputHeader.new({:station => s, :label => "Politician Name",:field_type => "text_data",:value => "Madhav Kumar Nepal", :required => true, :validation_format => "general"})
        CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20})
        CloudFactory::Form.create({:station => s, :title => "Guess the Amount", :description => "Guess the amount they have earned through bribe in Rupees"}) do |f|
          CloudFactory::FormField.new({:instruction => f, :label => "Amount", :field_type => "SA", :required => "true"})          
        end
      end
    end

    run = CloudFactory::Run.create(line, "2011 Ghotala", File.expand_path("human_worker_input.csv", __FILE__))
    
    haml :run
  end

  get '/style.css' do
    sass :style, :style => :expanded # overridden
  end

end