require 'singleton'
require 'nokogiri'
require 'open-uri'

module Beway

  class EbayDataParseError < StandardError; end;

  # EbayData
  #
  # Singleton class to handle ebay queries that are not auction-related.
  class EbayData

    include Singleton

    EBAY_OFFICIAL_TIME_URL = 'http://viv.ebay.com/ws/eBayISAPI.dll?EbayTime'

    def initialize
      @time_offset = nil
      @last_time_offset = nil
    end

    # The current ebay time as calculated by an offset from localtime.
    def time
      Time.now.localtime + self.time_offset
    end

    # The localtime offset from ebay time.
    #
    # add this offset to localtime to get an estimated ebay time
    def time_offset
      calc_time_offset unless @time_offset
      @time_offset
    end

    # Calculate the ebay time offset
    def calc_time_offset
      @last_time_offset = Time.now
      @time_offset = official_time - Time.now.localtime 
    end

    # Retrieve the official ebay time
    def official_time
      doc = Nokogiri::HTML(open(EBAY_OFFICIAL_TIME_URL))

      time_label = doc.at_xpath('//p[contains(text(), "The official eBay Time is now:")]')

      raise EbayDataParseError, "Couldn't find time label" unless time_label

      time_node = time_label.next_sibling.next_sibling
      raise EbayDataParseError, "Couldn't find time node" unless time_node

      time_str = time_node.inner_text
      time_re = /(Sun|Mon|Tues|Wednes|Thurs|Fri|Satur)day, (January|February|March|April|May|June|July|August|September|October|December) \d\d, 20\d\d \d\d:\d\d:\d\d P[SD]T/
      raise EbayDataParseError, "Time in unexpected format: #{time_str}" unless time_re.match(time_str)

      Time.parse(time_str).localtime
    end

    # Returns the number of seconds to some_ebay_time
    def seconds_to(some_ebay_time)
      some_ebay_time - time
    end

  end
end
