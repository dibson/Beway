require_relative '../lib/beway/auction'

HTML_DIR = File.dirname(__FILE__) + File::SEPARATOR + 'html' + File::SEPARATOR

AUCTIONS_VALID = []
AUCTIONS_BIN = []
AUCTIONS_COMPLETE = []

AUCTIONS_VALID << {
  :url => HTML_DIR + 'kodak-film-old.html',
  :description => 'Kodak Infrared, Kodacolor X, Kodachrome 8mm, Ektachrome E 120 Sealed Film',
  :current_bid => 'US $9.50',
  :min_bid => "US $10.00",
  :time_left => '9h 36m 50s',
  :end_time => 'May 07, 2012 18:16:22 PDT',
  :auction_number => '230785267328'
}
=begin
AUCTIONS_BIN << {
  :url => HTML_DIR + 'mens-cardigans-dutch-bin.html',
  :description => "St. John's Bay man Cardigans Size: S, M, L, XL, 2XL NEW",
}
AUCTIONS_COMPLETE << {
  :url => HTML_DIR + 'alfani-sweater-complete.html',
  :description => 'Alfani Grey V-Neck Merino Wool Size Small',
  :current_bid => 'US $9.99',
  :min_bid => nil,
  :time_left => nil,
  :end_time => 'Dec 26, 2010 20:09:00 PST',
  :auction_number => '270682427528',
}
=end

describe Beway::Auction do

  shared_examples_for "a valid auction" do

    describe "data retrieval" do
      it "should have the current bid" do
        auction.current_bid.should eq(data[:current_bid])
      end

      it "should have the description" do
        auction.description.should eq(data[:description])
      end

      it "should have the time left" do
        auction.time_left.should eq(data[:time_left])
      end

      it "should have the end time" do
        auction.end_time.should eq(Time.parse(data[:end_time]))
      end

      it "should have the auction number" do
        auction.auction_number.should eq(data[:auction_number])
      end

      it "should have the minimum bid" do
        auction.min_bid.should == data[:min_bid]
      end
    end
  end

  AUCTIONS_VALID.each do |a|
    describe "valid auction - #{a[:description]}" do
      auction = Beway::Auction.new(a[:url])

      it_should_behave_like "a valid auction" do
        let(:auction) { auction }
        let(:data) { a }
      end

      it "should have the has_bid_button? attribute set" do
        auction.has_bid_button?.should be_true
      end

      it "should not be marked as complete" do
        auction.complete?.should be_false
      end
    end
  end

  AUCTIONS_BIN.each do |a|
    describe "buy it now auction - #{a[:description]}" do
      it "should fail to initialize" do
        expect { Beway::Auction.new(a[:url]) }.to raise_error(Beway::InvalidUrlError)
      end
    end
  end

  AUCTIONS_COMPLETE.each do |a|
    describe "completed auction - #{a[:description]}" do

      auction = Beway::Auction.new(a[:url])

      it_should_behave_like "a valid auction" do
        let(:auction) { auction }
        let(:data) { a }
      end

      it "should be marked as complete" do
        auction.complete?.should be_true
      end

      it "should not has_bid_button?" do
        auction.has_bid_button?.should be_false
      end
    end
  end
end
