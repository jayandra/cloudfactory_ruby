require 'spec_helper'

module CloudFactory
  describe CloudFactory::RobotWorker do
    context "create a worker" do
      it "the plain ruby way" do
        worker = CloudFactory::RobotWorker.new(2, 0.2)
        worker.number.should eq(2)
        worker.reward.should eq(0.2)
      end
    end
  end
end