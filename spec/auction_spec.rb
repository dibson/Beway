require_relative '../lib/beway/auction'

HTML_DIR = File.dirname(__FILE__) + File::SEPARATOR + 'html' + File::SEPARATOR

AUCTIONS_VALID = []
AUCTIONS_BIN = []
AUCTIONS_COMPLETE = []

AUCTIONS_VALID << {
  :url => HTML_DIR + 'pink-sweater-bid-bin.html',
  :description => 'ALFANI  MENS SWEATER PINK SMALL  NEW WITH TAGS',
  :current_bid => 'US $14.99',
  :min_bid => 14.99,
  :time_left => '3h 28m 33s',
  :end_time => 'Dec 15, 2010 10:10:36 PST',
  :auction_number => '250740721413'
}
AUCTIONS_VALID << {
  :url => HTML_DIR + 'polo-lambs-wool.html',
  :description => 'NEW POLO RALPH LAUREN SWEATER MENS SMALL S LAMBSWOOL',
  :current_bid => 'US $27.00',
  :min_bid => 28.00,
  :time_left => '3h 35m 33s',
  :end_time => 'Dec 15, 2010 10:20:09 PST',
  :auction_number => '380297207180'
}
AUCTIONS_VALID << {
  :url => HTML_DIR + 'xmas-sweater.html',
  :current_bid => 'US $5.00',
  :min_bid => 5.50,
  :description => 'UGLY CHRISTMAS BIG BALLS SWEATER SZ S/M',
  :time_left => '1h 2m 44s',
  :end_time => 'Dec 15, 2010 07:42:16 PST',
  :auction_number => '270680279290'
}
AUCTIONS_VALID << {
  :url => HTML_DIR + 'pink-sweater-bid-bin.html',
  :description => 'ALFANI  MENS SWEATER PINK SMALL  NEW WITH TAGS',
  :current_bid => 'US $14.99',
  :min_bid => 14.99,
  :time_left => '3h 28m 33s',
  :end_time => 'Dec 15, 2010 10:10:36 PST',
  :auction_number => '250740721413'
}
AUCTIONS_VALID << {
  :url => HTML_DIR + 'cashmere-sweater.html',
  :description => 'Mens 100% CASHMERE SWEATER Gray 3 Button Collar L to XL',
  :current_bid => 'US $52.01',
  :min_bid => 53.01,
  :time_left => '0h 3m 15s',
  :end_time => 'Dec 26, 2010 20:36:09 PST',
  :auction_number => '260710322149'
}

AUCTIONS_BIN << {
  :url => HTML_DIR + 'mens-cardigans-dutch-bin.html',
  :description => "St. John's Bay man Cardigans Size: S, M, L, XL, 2XL NEW",
}
AUCTIONS_BIN << {
  :url => HTML_DIR + 'spring-mercer-bin-mo.html',
  :description => 'NWT Mens SPRING+MERCER L/S Shirt NEW Sz Small (S)',
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
AUCTIONS_COMPLETE << {
  :url => HTML_DIR + 'cashmere-sweater-complete.html',
  :description => 'Mens 100% CASHMERE SWEATER Gray 3 Button Collar L to XL',
  :current_bid => 'US $52.01',
  :min_bid => nil,
  :time_left => nil,
  :end_time => 'Dec 26, 2010 20:36:09 PST',
  :auction_number => '260710322149'
}



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
        auction.min_bid.should eq(data[:min_bid])
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
