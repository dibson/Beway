require 'nokogiri'
require 'open-uri'

module Beway
  class AuctionParseError < StandardError; end;
  class InvalidUrlError < StandardError; end;

  # Auction
  #
  # Represents an ebay auction.  Can only be instantiated for true auctions
  # (no buy-it-now-only sales) and completed auctions.
  class Auction

    attr_reader :url, :doc, :last_updated

    def initialize url
      @url = url
      refresh_doc
      raise InvalidUrlError unless valid_auction?
    end

    # can we represent this auction?
    def valid_auction?
      return true if complete? or has_bid_button?
      return false
    end

    # has bidding ended yet?
    def complete?
      complete_span = @doc.at_xpath('//span[contains(text(), "Bidding has ended on this item")]')
      return (complete_span.nil?) ? false : true
    end

    # fetch the url again
    def refresh_doc
      @doc = Nokogiri::HTML(open(@url))
      @last_updated = Time.now
    end

    # parsing method, returns a string
    def current_bid
      # list of ways to get the bid.
      xpaths = [
        "//th[contains(text(),'Current bid:')]",
        "//th[contains(text(),'Starting bid:')]",
        "//th[contains(text(),'Price:')]",
        "//td[contains(text(),'Starting bid:')]",
        "//td[contains(text(),'Winning bid:')]",
      ]

      bid_node = xpaths.reduce(nil) do |node, xpath|
        if node.nil?
          node = @doc.at_xpath(xpath)
          node = node.next_sibling unless node.nil?
        end
        node
      end

      raise AuctionParseError, "Couldn't find current/starting bid header in document" if bid_node.nil?
      bid_text = node_text(bid_node)
      bid_text = bid_text[/^[^\[]+/].strip if complete?
      return bid_text
    end

    # parsing method, returns a string
    def description
      desc = @doc.at_css('b#mainContent h1')
      raise AuctionParseError, "Couldn't find description in document" if desc.nil?
      desc.inner_text.strip
    end

    # parsing method, returns a string
    def time_left
      return nil if complete?

      time_str = node_text(time_node)
      time_str = time_str[/^[^(]*/].strip
      time_ar = time_str.split

      # time_ar comes to us looking like
      #   ["2d", "05h"] or ["0", "h", "12", "m", "5", "s"]
      # decide which, and roll with it...
      
      if time_ar[0][/^\d+d$/] and time_ar[1][/^\d+h$/]
        # ["2d", "05h"] style
        return time_ar.join(' ')
      else
        # assume ["0", "h", "12", "m", "5", "s"] style
        raise AuctionParseError, "Didn't find hour marker where expected" unless time_ar[1] == 'h'
        raise AuctionParseError, "Didn't find minute marker where expected" unless time_ar[3] == 'm'
        raise AuctionParseError, "Didn't find second marker where expected" unless time_ar[5] == 's'
        return [ time_ar[0] + time_ar[1],
                 time_ar[2] + time_ar[3],
                 time_ar[4] + time_ar[5] ].join(' ')
      end
    end

    # parsing method, returns a float
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

    # parsing method, returns a Time object
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

    # parsing method, returns a string
    def auction_number
      canonical_url_node = @doc.at_css('link[@rel = "canonical"]')
      raise AuctionParseError, "Couldn't find canonical URL" unless canonical_url_node
      canonical_url_node.attr('href')[/\d+$/]
    end

    # parsming method, returns boolean
    def has_bid_button?
      place_bid_button = @doc.at_xpath('//form//input[@value="Place bid"]')
      return (place_bid_button.nil?) ? false : true
    end

    private

    # fetch the node containing the end time
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

    # a string of all text nodes below n, concatenated
    def node_text(n)
      t = ''
      n.traverse { |e| t << ' ' + e.to_s if e.text? }
      t.gsub(/ +/, ' ').strip
    end

  end
end
