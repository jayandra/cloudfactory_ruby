require 'spec_helper'

describe CloudFactory::Worker do
  context "create a worker" do
    it "the plain ruby way" do
      worker = CloudFactory::Worker.new()
      worker.count.should eq(1)
    end
  end
end