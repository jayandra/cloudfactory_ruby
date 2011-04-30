describe CloudFactory::Food do
  it "broccoli is gross" do
    CloudFactory::Food.portray("Broccoli").should eql("Gross!")
  end
  
  it "anything else is delicious" do
    CloudFactory::Food.portray("Not Broccoli").should eql("Delicious!")
  end
end
