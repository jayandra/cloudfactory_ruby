require 'spec_helper'

module CloudFactory
  describe CloudFactory::GoogleTranslator do
    context "create a google translator worker" do
      it "the plain ruby way" do
        worker = CloudFactory::GoogleTranslator.create
        worker.number.should eq(1)
        worker.reward.should be_nil
      end
    end
  end
end