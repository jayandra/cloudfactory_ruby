module CF
  class HumanWorker
    include Client
    require 'httparty'
    extend ActiveSupport::Concern
    
    attr_accessor :id, :number, :reward, :station, :stat_badge, :skill_badges, :errors, :badge
    
    def initialize(options={})
      @skill_badges = []
      @station = options[:station]
      @number  = options[:number].nil? ? 1 : options[:number]
      @reward  = options[:reward]
      @badge = options[:skill_badge].nil? ? nil : options[:skill_badge]
      @stat_badge = options[:stat_badge].nil? ? nil : options[:stat_badge]
      if @station
        if options[:skill_badge].nil? && options[:stat_badge].nil?
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
              :skill_badge => @badge,
              :stat_badge => options[:stat_badge]
            }
          }
        end
        resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{@station.line['title'].downcase}/stations/#{@station.index}/workers.json",request)
        
        self.id =  resp.parsed_response['id']
        self.number =  resp.parsed_response['number']
        self.reward =  resp.parsed_response['reward']
        self.stat_badge =  resp.parsed_response['stat_badge'] 
        @skill_badges << resp.parsed_response['skill_badges']
        
        if resp.code != 200
          self.errors = resp.parsed_response['error']['message']
        end
        self.station = options[:station]
        self.station.worker = self
      end
    end
    
    def badge=(badge)
      request = 
      {
        :body => 
        {
          :api_key => CF.api_key,
          :skill_badge => badge
        }
      }
      resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{@station.line['title'].downcase}/stations/#{@station.index}/workers/#{self.id}/badge.json",request)
      self.skill_badges << resp.parsed_response['skill_badges']
    end
  end
end