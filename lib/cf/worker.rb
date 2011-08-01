module CF
  module Worker
    require 'httparty'
    extend ActiveSupport::Concern
    include Client

    included do |base|
      host = base.to_s.split("::").last
      # Number of worker 
      attr_accessor :number
      # Amount of money assigned for worker
      attr_accessor :reward
      attr_accessor :stat_badge, :skill_badges, :badge
      attr_accessor :station
      attr_accessor :id, :data, :from, :to 
      attr_accessor :url, :audio_quality, :video_quality
      attr_accessor :document, :query
      attr_accessor :sanitize
      attr_accessor :max_retrieve, :show_source_text
      attr_accessor :template, :template_variables
      attr_accessor :split_duration, :overlapping_time
      attr_accessor :append, :separator
      attr_accessor :settings
      attr_accessor :content, :keywords
      attr_accessor :errors

      case host
      when "HumanWorker"
        # Initializes new worker
        def initialize(options={})
          @station = options[:station]
          @number  = options[:number].nil? ? 1 : options[:number]
          @reward  = options[:reward]
          @badge = options[:badge].nil? ? nil : options[:badge]
          if @station
            if @badge.nil?
              request = 
              {
                :body => 
                {
                  :api_key => CF.api_key,
                  :worker => {:number => @number, :reward => @reward, :type => "HumanWorker"}
                }
              }
            else
              request = 
              {
                :body => 
                {
                  :api_key => CF.api_key,
                  :worker => {:number => @number, :reward => @reward, :type => "HumanWorker"},
                  :badge => @badge
                }
              }
            end
            resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{@station.line['title'].downcase}/stations/#{@station.index}/workers.json",request)
            worker = CF::HumanWorker.new({})
            resp.parsed_response.to_hash.each_pair do |k,v|
              worker.send("#{k}=",v) if worker.respond_to?(k)
            end
            if resp.code != 200
              worker.errors = resp.parsed_response['error']['message']
            end
            worker.station = @station
            @station.worker = worker
          end
        end
      else
        # Creates new worker 
        def self.create(options={})
          @station = options[:station]
          type = self.to_s.split("::").last.underscore
          worker = self.new
          worker.instance_eval do
            @number = 1
            @reward = 0
            if type == "google_translate_robot"
              @data = options[:data]
              @from = options[:from]
              @to = options[:to]
            elsif type == "media_converter_robot"
              @url = options[:url]
              @to = options[:to]
              @audio_quality = options[:audio_quality]
              @video_quality = options[:video_quality]
            elsif type == "content_scraping_robot"
              @document = options[:document]
              @query = options[:query]
            elsif type == "sentiment_robot"
              @document = options[:document]
              @sanitize = options[:sanitize]
            elsif type == "term_extraction_robot"
              @url = options[:url]
              @max_retrieve = options[:max_retrieve]
              @show_source_text = options[:show_source_text]
            elsif type == "text_appending_robot"
              @append = options[:append]
              @separator = options[:separator]
            elsif type == "mailer_robot"
              @to = options[:to]
              @template = options[:template]
              @template_variables = options[:template_variables]
            elsif type == "entity_extraction_robot"
              @document = options[:document]
            elsif type == "media_splitting_robot"
              @url = options[:url]
              @split_duration  = options[:split_duration]
              @overlapping_time = options[:overlapping_time]
            elsif type == "image_processing_robot"
              options.delete(:station)
              @settings = options    
            elsif type == "concept_tagging_robot"
              @url = options[:url]   
            elsif type == "text_extraction_robot"
              @url = options[:url]
            elsif type == "keyword_matching_robot"
              @content = options[:content]       
              @keywords = options[:keywords]
            end
          end
          if @station
            if type == "google_translate_robot"
              resp = self.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/workers.json", :worker => {:number => 1, :reward => 0, :type => type, :data => options[:data], :from => options[:from], :to => options[:to]})
              resp.to_hash.each_pair do |k,v|
                worker.send("#{k}=",v) if worker.respond_to?(k)
              end
              if resp.code != 200
                worker.errors = resp.error.message
              end
              worker.station = @station
              @station.worker = worker
            elsif type == "media_converter_robot"
              resp = self.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/workers.json", :worker => {:type => "MediaConverterRobot", :url => options[:url], :to => options[:to], :audio_quality => options[:audio_quality], :video_quality => options[:video_quality]})
              resp.to_hash.each_pair do |k,v|
                worker.send("#{k}=",v) if worker.respond_to?(k)
              end
              if resp.code != 200
                worker.errors = resp.error.message
              end
              worker.station = @station
              @station.worker = worker
            elsif type == "content_scraping_robot"
              resp = self.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/workers.json", :worker => {:type => "ContentScrapingRobot", :document => options[:document], :query => options[:query]})
              resp.to_hash.each_pair do |k,v|
                worker.send("#{k}=",v) if worker.respond_to?(k)
              end
              if resp.code != 200
                worker.errors = resp.error.message
              end
              worker.station = @station
              @station.worker = worker
            elsif type == "sentiment_robot"
              resp = self.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/workers.json", :worker => {:type => "SentimentRobot", :document => options[:document], :sanitize => options[:sanitize]})
              resp.to_hash.each_pair do |k,v|
                worker.send("#{k}=",v) if worker.respond_to?(k)
              end
              if resp.code != 200
                worker.errors = resp.error.message
              end
              worker.station = @station
              @station.worker = worker
            elsif type == "term_extraction_robot"
              resp = self.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/workers.json", :worker => {:type => "TermExtractionRobot", :url => options[:url], :max_retrieve => options[:max_retrieve], :show_source_text => options[:show_source_text]})
              resp.to_hash.each_pair do |k,v|
                worker.send("#{k}=",v) if worker.respond_to?(k)
              end
              if resp.code != 200
                worker.errors = resp.error.message
              end
              worker.station = @station
              @station.worker = worker
            elsif type == "text_appending_robot"
              resp = self.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/workers.json", :worker => {:type => "TextAppendingRobot", :append => options[:append], :separator => options[:separator]})
              resp.to_hash.each_pair do |k,v|
                worker.send("#{k}=",v) if worker.respond_to?(k)
              end
              if resp.code != 200
                worker.errors = resp.error.message
              end
              worker.station = @station
              @station.worker = worker
            elsif type == "mailer_robot"
              resp = self.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/workers.json", :worker => {:type => "MailerRobot", :to => options[:to], :template => options[:template], :template_variables => options[:template_variables]})
              resp.to_hash.each_pair do |k,v|
                worker.send("#{k}=",v) if worker.respond_to?(k)
              end
              if resp.code != 200
                worker.errors = resp.error.message
              end
              worker.station = @station
              @station.worker = worker
            elsif type == "entity_extraction_robot"
              resp = self.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/workers.json", :worker => {:type => "EntityExtractionRobot", :document => options[:document]})
              resp.to_hash.each_pair do |k,v|
                worker.send("#{k}=",v) if worker.respond_to?(k)
              end
              if resp.code != 200
                worker.errors = resp.error.message
              end
              worker.station = @station
              @station.worker = worker
            elsif type == "media_splitting_robot"
              resp = self.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/workers.json", :worker => {:type => "MediaSplittingRobot", :url => options[:url], :split_duration => options[:split_duration], :overlapping_time => options[:overlapping_time]})
              resp.to_hash.each_pair do |k,v|
                worker.send("#{k}=",v) if worker.respond_to?(k)
              end
              if resp.code != 200
                worker.errors = resp.error.message
              end
              worker.station = @station
              @station.worker = worker
            elsif type == "image_processing_robot"              
              @settings = options
              resp = self.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/workers.json", :worker => options.merge(:type => "ImageProcessingRobot"))
              resp.to_hash.each_pair do |k,v|
                worker.send("#{k}=",v) if worker.respond_to?(k)
              end
              if resp.code != 200
                worker.errors = resp.error.message
              end
              worker.station = @station
              @station.worker = worker
            elsif type == "concept_tagging_robot"
              resp = self.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/workers.json", :worker => {:type => "ConceptTaggingRobot", :url => options[:url]})
              resp.to_hash.each_pair do |k,v|
                worker.send("#{k}=",v) if worker.respond_to?(k)
              end
              if resp.code != 200
                worker.errors = resp.error.message
              end
              worker.station = @station
              @station.worker = worker              
             elsif type == "keyword_matching_robot"
                resp = self.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/workers.json", :worker => {:type => "KeywordMatchingRobot", :content => options[:content], :keywords => options[:keywords]})
                resp.to_hash.each_pair do |k,v|
                  worker.send("#{k}=",v) if worker.respond_to?(k)
                end
                if resp.code != 200
                  worker.errors = resp.error.message
                end
                worker.station = @station
                @station.worker = worker
             elsif type == "text_extraction_robot"
                resp = self.post("/lines/#{CF.account_name}/#{@station.line_title.downcase}/stations/#{@station.index}/workers.json", :worker => {:type => "TextExtractionRobot", :url => options[:url]})
                resp.to_hash.each_pair do |k,v|
                  worker.send("#{k}=",v) if worker.respond_to?(k)
                end
                if resp.code != 200
                  worker.errors = resp.error.message
                end
                worker.station = @station
                @station.worker = worker
            end
          else
            return worker
          end
        end
      end
    end
  end
end