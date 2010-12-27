require 'nokogiri'
require 'open-uri'

module Beway
  class ParseError < StandardError; end;
  class InvalidUrlError < StandardError; end;

  class Auction

    attr_reader :url, :doc, :last_updated

    def initialize url
      @url = url
      refresh_doc
      raise InvalidUrlError unless has_bid_button?
    end

    def refresh_doc
      @doc = Nokogiri::HTML(open(@url))
      @last_updated = Time.now
    end

    def current_bid
      th = @doc.at_xpath("//th[contains(text(),'Current bid:')]")
      th = @doc.at_xpath("//th[contains(text(),'Starting bid:')]") unless th
      th = @doc.at_xpath("//th[contains(text(),'Price:')]") unless th
      raise ParseError, "Couldn't find current/starting bid header in document" if th.nil?
      current_bid = th.parent.at_css('td')
      raise ParseError, "Couldn't find current/starting bid data in document" if current_bid.nil?
      node_text(current_bid)
    end

    def description
      desc = @doc.at_css('b#mainContent h1')
      raise ParseError, "Couldn't find description in document" if desc.nil?
      desc.inner_text.strip
    end

    def time_left
      time_str = node_text(time_node)
      time_str = time_str[/^[^(]*/].strip
      time_ar = time_str.split
      raise ParseError, "Didn't find hour marker where expected" unless time_ar[1] == 'h'
      raise ParseError, "Didn't find minute marker where expected" unless time_ar[3] == 'm'
      raise ParseError, "Didn't find second marker where expected" unless time_ar[5] == 's'
      time_ar[0] + 'h ' + time_ar[2] + 'm ' + time_ar[4] + 's'
    end

    def min_bid
      max_label = @doc.at_xpath("//th/label[contains(text(),'Your max bid:')]")
      raise ParseError, "Couldn't find max bid label in document" unless max_label
      min_bid_node = max_label.parent.parent.next_sibling
      raise ParseError, "Couldn't find minimum bid in document" unless min_bid_node
      md = /\(Enter ([^)]*) or more\)/.match min_bid_node.inner_text
      raise ParseError, "Min Bid data not in expected format" if md.nil?
      md[1]
    end

    def end_time
      node_text(time_node).match(/\(([^)]*)\)/)[1]
    end

    def auction_number
      canonical_url_node = @doc.at_css('link[@rel = "canonical"]')
      raise ParseError, "Couldn't find canonical URL" unless canonical_url_node
      canonical_url_node.attr('href')[/\d+$/]
    end

    def has_bid_button?
      place_bid_button = @doc.at_css('input#but_v4-7')
      return (place_bid_button.nil?) ? false : true
    end

    private

    def time_node
      th = @doc.at_xpath("//th[contains(text(),'Time left:')]")
      raise ParseError, "Couldn't find Time Left header" unless th
      node = th.parent.at_css('td')
      raise ParseError, "Couldn't find Time node" unless node
      node
    end

    def node_text(n)
      t = ''
      n.traverse { |e| t << ' ' + e.to_s if e.text? }
      t.gsub(/ +/, ' ').strip
    end

  end
end
