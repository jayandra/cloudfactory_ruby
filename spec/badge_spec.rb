require 'spec_helper'

module CF
  describe CF::HumanWorker do
    context "create badge" do
      it "should create multiple badge for worker" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "human_worker/block/create-multiple-badge", :record => :new_episodes do
          badge = 
          {
            :title => 'Football Fanatic', 
            :description => "This qualification allows you to perform work at stations which have this badge.", 
            :max_badges => 3, 
            :test => 
            {
              :input => {:name => "Lionel Andres Messi", :country => "Argentina"},
              :expected_output => 
              [{:birthplace => "Rosario, Santa Fe, Argentina",:match_options => {:tolerance => 10, :ignore_case => true }},{:position => "CF",:match_options => {:tolerance => 1 }},{:"current-club" => "Barcelona",:match_options => {:tolerance => 1, :ignore_case => false }}]
            }
          }
          badge_1 = 
          {
            :title => 'Football Fanatic', 
            :description => "This qualification allows you to perform work at stations which have this badge.", 
            :max_badges => 3, 
            :test => 
            {
              :input => {:name => "Cristiano Ronaldo", :country => "Portugal"},
              :expected_output => 
              [{:birthplace => "Rosario, Santa Fe, Portugal",:match_options => {:tolerance => 10, :ignore_case => true }},{:position => "CF",:match_options => {:tolerance => 1 }},{:"current-club" => "Real Madrid",:match_options => {:tolerance => 1, :ignore_case => false }}]
            }
          }
          line = CF::Line.create("badge_in_worker", "Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
            CF::Station.create({:line =>l, :type => "work"}) do |s|
              CF::HumanWorker.new({:station => s, :number => 2, :reward => 20, :skill_badge => badge})
            end
          end
          line.stations.first.worker.badge = badge_1
          line.stations.first.type.should eql("WorkStation")
          line.stations.first.worker.number.should eql(2)
          line.stations.first.worker.reward.should eql(20)
          line.stations.first.worker.skill_badges.first.should eql([{"title"=>"Football Fanatic", "description"=>"This qualification allows you to perform work at stations which have this badge.", "score"=>nil, "speed"=>nil, "quality_rating"=>nil, "max_badges"=>3, "skill_test"=>{"score_after"=>"submit", "manual_scoring"=>false, "display_answers"=>false, "edit_answers"=>true, "retries"=>0, "pass_percentage"=>100, "test_units"=>[{"input"=>{"name"=>"Lionel Andres Messi", "country"=>"Argentina"}, "expected_output"=>[{"birthplace"=>"Rosario, Santa Fe, Argentina", "match_options"=>{"tolerance"=>"1", "ignore_case"=>"false"}, "position"=>"CF", "current-club"=>"Barcelona"}], "match_options"=>{"tolerance"=>0, "ignore_case"=>false}}]}}])
          line.stations.first.worker.skill_badges.last.should eql([{"title"=>"Football Fanatic", "description"=>"This qualification allows you to perform work at stations which have this badge.", "score"=>nil, "speed"=>nil, "quality_rating"=>nil, "max_badges"=>3, "skill_test"=>{"score_after"=>"submit", "manual_scoring"=>false, "display_answers"=>false, "edit_answers"=>true, "retries"=>0, "pass_percentage"=>100, "test_units"=>[{"input"=>{"name"=>"Cristiano Ronaldo", "country"=>"Portugal"}, "expected_output"=>[{"birthplace"=>"Rosario, Santa Fe, Portugal", "match_options"=>{"tolerance"=>"1", "ignore_case"=>"false"}, "position"=>"CF", "current-club"=>"Real Madrid"}], "match_options"=>{"tolerance"=>0, "ignore_case"=>false}}]}}])
          line.stations.first.worker.stat_badge.should eql({"approval_rating"=>80, "assignment_duration"=>3600, "abandonment_rate"=>30, "country"=>nil})
        end
      end
      
      it "should create stat badge for worker in block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "human_worker/block/create-stat-badge", :record => :new_episodes do
          stat_badge = {:approval_rating => 40, :assignment_duration => 1800}
          line = CF::Line.create("stat_badge_in_worker", "Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
            CF::Station.create({:line =>l, :type => "work"}) do |s|
              CF::HumanWorker.new({:station => s, :number => 2, :reward => 20, :stat_badge => stat_badge})
            end
          end
          line.stations.first.type.should eql("WorkStation")
          line.stations.first.worker.number.should eql(2)
          line.stations.first.worker.reward.should eql(20)
          line.stations.first.worker.stat_badge.should eql({"approval_rating"=>40, "assignment_duration"=>1800, "abandonment_rate"=>30, "country"=>nil})
        end
      end
      
      it "should create stat badge for worker in plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "human_worker/plain-ruby/create-stat-badge", :record => :new_episodes do
          stat_badge = {:approval_rating => 40, :assignment_duration => 1800}
          line = CF::Line.new("stat_badge_in_worker_1", "Digitization")
          input_format = CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker = CF::HumanWorker.new({:number => 2, :reward => 20, :stat_badge => stat_badge})
          line.stations.first.worker = worker
          
          line.stations.first.type.should eql("WorkStation")
          line.stations.first.worker.number.should eql(2)
          line.stations.first.worker.reward.should eql(20)
          line.stations.first.worker.stat_badge.should eql({"approval_rating"=>40, "assignment_duration"=>1800, "abandonment_rate"=>30, "country"=>nil})
        end
      end
    end
  end
end