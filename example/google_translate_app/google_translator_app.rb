class GoogleTranslatorApp < Sinatra::Base
  
  set :haml, :format => :html5
  set :sass, :style => :compact # default Sass style is :nested

  configure do
    # CloudFactory.api_key = "133fcabc51e35903e616c25aace7ffccc819c8f0"
    # CloudFactory.email     = "sachin@sproutify.com"
    # CloudFactory.api_url = "sprout.lvh.me:3000/api/"
    # CloudFactory.api_version = "v1"
  end
  
  get '/' do
    haml :index
    
  end
  
  get '/run' do
    # CloudFactory.api_url = "sprout.lvh.me:3000/api/"
    response = RestClient.get 'http://sprout.lvh.me:3000/api/v1/lines.json', {:accept => :json}
    # @categories = CloudFactory::Category.all
    
    # @categories = RestClient.get 'http://sprout.lvh.me:3000/api/v1/categories.json', {:accept => :json}
    # attrs = {:label => "image_url",
    #  :field_type => "text_data",
    #  :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
    #  :required => true, 
    #  :validation_format => "url"
    # }
    # 
    # line = CloudFactory::Line.new("Demo Line","Survey")
    
    # line = CloudFactory::Line.create("Demo Line","Survey") do |l|
    #  CloudFactory::InputHeader.new(line, attrs)
    #  CloudFactory::Station.create(l, :type => "work") do |s|
    #    CloudFactory::HumanWorker.new(s, 2, 0.2)
    #    CloudFactory::StandardInstruction.create(s,{:title => "Enter name of the CEO of Google", :description => "Enter name of the CEO of Google"}) do |i|
    #      CloudFactory::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
    #      CloudFactory::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
    #      CloudFactory::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})            
    #    end
    #  end
    # end
    # run = CloudFactory::Run.create(line, "run name", File.expand_path("test.csv", __FILE__))
    # 
    haml :run
  end

  get '/style.css' do
    sass :style, :style => :expanded # overridden
  end

end