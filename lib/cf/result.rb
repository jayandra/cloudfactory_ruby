module CF
  class Result
    include Client
    attr_accessor :meta_data, :results, :unit_id
    
    def self.get_result(run_id)
      resp = get("/runs/#{run_id}/results.json")
      
      @results =[]
      resp.each do |r|
        result = self.new()
        r.to_hash.each_pair do |k,v|
          result.send("#{k}=",v) if result.respond_to?(k)
        end
        @results << result
      end
      return @results
    end
  end
end