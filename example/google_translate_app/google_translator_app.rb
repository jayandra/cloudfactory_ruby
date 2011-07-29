class GoogleTranslatorApp < Sinatra::Base
  
  set :haml, :format => :html5
  set :sass, :style => :compact # default Sass style is :nested

  configure do
    # CF.api_key = "133fcabc51e35903e616c25aace7ffccc819c8f0"
    # CF.email     = "sachin@sproutify.com"
    # CF.api_url = "sprout.lvh.me:3000/api/"
    # CF.api_version = "v1"
  end
  
  get '/' do
    haml :index
    
  end
  
  get '/run' do
    # CF.api_url = "sprout.lvh.me:3000/api/"
    response = RestClient.get 'http://sprout.lvh.me:3000/api/v1/lines.json', {:accept => :json}
    # @categories = CF::Category.all
    
    # @categories = RestClient.get 'http://sprout.lvh.me:3000/api/v1/categories.json', {:accept => :json}
    # attrs = {:label => "image_url",
    #  :field_type => "text_data",
    #  :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg", 
    #  :required => true, 
    #  :validation_format => "url"
    # }
    # 
    # line = CF::Line.new("Demo Line","Survey")
    
    # line = CF::Line.create("Demo Line","Survey") do |l|
    #  CF::InputHeader.new(line, attrs)
    #  CF::Station.create(l, :type => "work") do |s|
    #    CF::HumanWorker.new(s, 2, 0.2)
    #    CF::StandardInstruction.create(s,{:title => "Enter name of the CEO of Google", :description => "Enter name of the CEO of Google"}) do |i|
    #      CF::FormField.new(s, {:label => "First Name", :field_type => "SA", :required => "true"})
    #      CF::FormField.new(s, {:label => "Middle Name", :field_type => "SA"})
    #      CF::FormField.new(s, {:label => "Last Name", :field_type => "SA", :required => "true"})            
    #    end
    #  end
    # end
    # run = CF::Run.create(line, "run name", File.expand_path("test.csv", __FILE__))
    # 
    haml :run
  end

  get '/style.css' do
    sass :style, :style => :expanded # overridden
  end

end