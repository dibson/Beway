require_relative '../lib/beway/auction'

HTML_DIR = File.dirname(__FILE__) + File::SEPARATOR + 'html' + File::SEPARATOR

AUCTION_MENS_CARDIGAN_DUTCH_BIN = HTML_DIR + 'mens-cardigans-duthch-bin.html'
AUCTION_PINK_SWEATER_BID_BIN = HTML_DIR + 'pink-sweater-bid-bin.html'
AUCTION_SPRING_MERCER_BIN_MO = HTML_DIR + 'spring-mercer-bin-mo.html'

AUCTION_POLO_LAMBS_WOOL = HTML_DIR + 'polo-lambs-wool.html'
AUCTION_XMAS_SWEATER = {
  :url => HTML_DIR + 'xmas-sweater.html',
  :current_bid => 'US $5.00',
  :min_bid => 'US $5.50',
  :description => 'UGLY CHRISTMAS BIG BALLS SWEATER SZ S/M',
  :time_left => '1h 2m 44s',
  :end_time => 'Dec 15, 2010 07:42:16 PST',
  :auction_number => '270680279290'
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
      auction.end_time.should eq(data[:end_time])
    end

    it "should have the auction number" do
      auction.auction_number.should eq(data[:auction_number])
    end

    it "should have the minimum bid" do
      auction.min_bid.should eq(data[:min_bid])
    end
    end
  end

  context "with any url" do
    url = 'http://www.google.com/'
    a = Beway::Auction.new(url)

    it "should initialize with a string, the file/url to parse" do
      a.should be_a Beway::Auction
      a.url.should be_a String
    end

    it "should keep a nokogiri document of given url/file" do
      a.doc.should be_a Nokogiri::HTML::Document
    end

    it "should refresh the document" do
      a.refresh_doc
      a.doc.should be_a Nokogiri::HTML::Document
    end

    it "should know when it last updated" do
      t = a.last_updated
      a.last_updated.should be_an_instance_of Time
      sleep 1
      a.refresh_doc
      a.last_updated.should > t
    end

  end

  describe "auction - x-mas sweater" do
    it_should_behave_like "a valid auction" do
      let(:auction) { Beway::Auction.new(AUCTION_XMAS_SWEATER[:url]) }
      let(:data) { AUCTION_XMAS_SWEATER }
    end
  end

end
