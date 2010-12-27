require 'nokogiri'
require 'open-uri'

module Beway
  class AuctionParseError < StandardError; end;
  class InvalidUrlError < StandardError; end;

  class Auction

    attr_reader :url, :doc, :last_updated

    def initialize url
      @url = url
      refresh_doc
      raise InvalidUrlError unless valid_auction?
    end

    def valid_auction?
      return true if complete? or has_bid_button?
      return false
    end

    def complete?
      complete_span = @doc.at_xpath('//span[contains(text(), "Bidding has ended on this item")]')
      return (complete_span.nil?) ? false : true
    end

    def refresh_doc
      @doc = Nokogiri::HTML(open(@url))
      @last_updated = Time.now
    end

    def current_bid

      # list of ways to get the bid.
      # grab the xpath from the doc, if found, use the associated lambda to grab the data
      bid_xpath_lambda = [
        ["//th[contains(text(),'Current bid:')]", lambda { |n| n.parent.at_css('td') } ],
        ["//th[contains(text(),'Starting bid:')]", lambda { |n| n.parent.at_css('td') } ],
        ["//th[contains(text(),'Price:')]", lambda { |n| n.parent.at_css('td') } ],
        ["//td[contains(text(),'Starting bid:')]", lambda { |n| n.next_sibling } ],
        ["//td[contains(text(),'Winning bid:')]", lambda { |n| n.next_sibling } ],
      ]

      bid = bid_xpath_lambda.reduce(nil) do |bid, xl|
        if bid.nil?
          xpath, node_to_bid = xl
          node = @doc.at_xpath(xpath)
          if node.nil?
            nil
          else
            node_to_bid.call(node)
          end
        else
          bid
        end
      end

      raise AuctionParseError, "Couldn't find current/starting bid header in document" if bid.nil?
      bid_text = node_text(bid)

      return bid_text if not complete?

      return bid_text[/^[^\[]+/].strip

    end

    def description
      desc = @doc.at_css('b#mainContent h1')
      raise AuctionParseError, "Couldn't find description in document" if desc.nil?
      desc.inner_text.strip
    end

    def time_left
      return nil if complete?

      time_str = node_text(time_node)
      time_str = time_str[/^[^(]*/].strip
      time_ar = time_str.split
      raise AuctionParseError, "Didn't find hour marker where expected" unless time_ar[1] == 'h'
      raise AuctionParseError, "Didn't find minute marker where expected" unless time_ar[3] == 'm'
      raise AuctionParseError, "Didn't find second marker where expected" unless time_ar[5] == 's'
      time_ar[0] + 'h ' + time_ar[2] + 'm ' + time_ar[4] + 's'
    end

    def min_bid
      return nil if complete?

      max_label = @doc.at_xpath("//th/label[contains(text(),'Your max bid:')]")
      raise AuctionParseError, "Couldn't find max bid label in document" unless max_label
      min_bid_node = max_label.parent.parent.next_sibling
      raise AuctionParseError, "Couldn't find minimum bid in document" unless min_bid_node
      md = /\(Enter ([^)]*) or more\)/.match min_bid_node.inner_text
      raise AuctionParseError, "Min Bid data not in expected format" if md.nil?
      md[1][/\d*\.\d*/].to_f
    end

    def end_time
      text = node_text(time_node)
      md = text.match(/\(([^)]*)\)/)
      if md
        time_str = md[1]
      else
        time_str = text
      end
      raise AuctionParseError unless time_str
      Time.parse(time_str)
    end

    def auction_number
      canonical_url_node = @doc.at_css('link[@rel = "canonical"]')
      raise AuctionParseError, "Couldn't find canonical URL" unless canonical_url_node
      canonical_url_node.attr('href')[/\d+$/]
    end

    def has_bid_button?
      place_bid_button = @doc.at_xpath('//form//input[@value="Place bid"]')
      return (place_bid_button.nil?) ? false : true
    end

    private

    def time_node
      if complete?
        td = @doc.at_xpath("//td[contains(text(),'Ended:')]")
        raise AuctionParseError, "Couldn't find ended header" unless td
        node = td.next_sibling
      else
        th = @doc.at_xpath("//th[contains(text(),'Time left:')]")
        raise AuctionParseError, "Couldn't find Time Left header" unless th
        node = th.parent.at_css('td')
      end

      raise AuctionParseError, "Couldn't find Time node" unless node
      node
    end

    def node_text(n)
      t = ''
      n.traverse { |e| t << ' ' + e.to_s if e.text? }
      t.gsub(/ +/, ' ').strip
    end

  end
end
