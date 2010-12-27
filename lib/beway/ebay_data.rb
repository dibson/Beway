require 'singleton'
require 'nokogiri'
require 'open-uri'

module Beway

  class EbayDataParseError < StandardError; end;

  class EbayData

    include Singleton

    EBAY_OFFICIAL_TIME_URL = 'http://viv.ebay.com/ws/eBayISAPI.dll?EbayTime'

    def initialize
      @time_offset = nil
      @last_time_offset = nil
    end

    def time
      Time.now.localtime + self.time_offset
    end

    def time_offset
      set_time_offset unless @time_offset
      @time_offset
    end

    def set_time_offset
      @last_time_offset = Time.now
      @time_offset = official_time - Time.now.localtime 
    end

    def official_time
      doc = Nokogiri::HTML(open(EBAY_OFFICIAL_TIME_URL))

      time_label = doc.at_xpath('//p[contains(text(), "The official eBay Time is now:")]')

      raise EbayDataParseError, "Couldn't find time label" unless time_label

      time_node = time_label.next_sibling.next_sibling
      raise EbayDataParseError, "Couldn't find time node" unless time_node

      time_str = time_node.inner_text
      time_re = /(Sun|Mon|Tues|Wednes|Thurs|Fri|Satur)day, (January|February|March|April|May|June|July|August|September|October|December) \d\d, 20\d\d \d\d:\d\d:\d\d PST/
      raise EbayDataParseError, "Time in unexpected format" unless time_re.match(time_str)

      Time.parse(time_str).localtime
    end

  end
end
