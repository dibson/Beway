require_relative '../lib/beway/ebay_data'

describe Beway::EbayData do

  it "should return the current ebay time" do
    t = Beway::EbayData.instance.official_time
    t.should be_an_instance_of Time
  end

  it "should make a reasonable guess as to the current ebay time" do
    ebay = Beway::EbayData.instance
    ebay.time_offset.should be_a Float
    (ebay.time - ebay.official_time).should be < 2
    (ebay.time - ebay.official_time).should be > -2
  end

end
