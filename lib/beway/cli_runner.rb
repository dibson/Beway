require_relative '../beway.rb'

module Beway

  class CliRunner

    BID_THRESHOLD = 10

    def self.start
      runner = self.new
      runner.run
    end

    def initialize
    end

    def run
      
      display_intro

      # login prep
      user = prompt_username
      pass = prompt_password
      bidder = Bidder.new(user, pass)
      puts "Logging in..."
      bidder.login
      if bidder.logged_in
        puts "          ...success"
      else
        puts "Bad ebay username/password combo!  Please try again."
        exit
      end

      # bid prep
      auction = auction_from_user
      bid_amount = bid_for_auction_from_user(auction)

      # our tools
      ebay = EbayData.instance

      loop do
        display_auction auction

        seconds_to_end = ebay.seconds_to(auction.end_time)

        if seconds_to_end <= BID_THRESHOLD
          puts "Placing bid..."
          bidder.bid(auction.url, bid_amount)
          puts "           ...placed."
          puts "Sleeping til end of auction..."
          sleep ebay.seconds_to(auction.end_time).ceil
          auction.refresh_doc
          display_auction auction
          exit
        end

        seconds = seconds_to_end.floor / 2
        seconds = 5 if seconds_to_end < (2 * BID_THRESHOLD)
        puts "Sleeping #{seconds} seconds..."
        sleep seconds

        puts "Updating auction..."
        puts
        auction.refresh_doc
      end
    end

    def bid_for_auction_from_user(a)
      loop do
        bid_amount = prompt_bid()#a.min_bid)
        return bid_amount if prompt_confirm_bid(bid_amount)
      end
    end

    def auction_from_user
      loop do
        begin
          auction = Auction.new(prompt_url)
          if auction.complete?
            display_auction auction
            puts
            puts "That auction is done already!  Try another, or 'exit' to quit."
            next
          end
        rescue AuctionParseError
          puts "Sorry, we can't parse that url as an auction"
          next
        end

        return auction if prompt_confirm_auction(auction)
      end
    end

    def display_intro
      puts "Welcome to Beway's CLI interface"
    end

    def display_auction(a)
      puts
      puts "URL:            #{a.url}"
      puts "Description:    #{a.description}"
      puts "Auction Number: #{a.auction_number}"
      puts "Current Bid:    #{a.current_bid}"
      puts "Min Bid:        #{a.min_bid || '-- bidding closed --'}"
      puts "Time Left:      #{a.time_left || '-- bidding closed --'}"
      puts "End Time:       #{a.end_time}"
    end

    def prompt_username
      print "Enter eBay username >> "
      return get_user_input.chomp
    end

    def prompt_password
      print "Enter eBay password >> "
      system "stty -echo"
      pass = get_user_input
      system "stty echo"
      puts

      pass.chomp
    end

    def prompt_bid(min=nil)
      print "Enter your bid for the item >> "
      bid = get_user_input.to_f
      puts
      return bid if min.nil? or bid >= min
      puts "The minimum bid for this auction is #{min}.  Try again, or type 'exit' to quit."
      prompt_bid(min)
    end

    def prompt_confirm_bid(amount)
      printf "Are you sure you want to bid %.2f? (y\\n) >> ", amount
      confirm = get_user_input
      puts
      if confirm.downcase.chr == 'y'
        true
      else
        false
      end
    end

    def prompt_confirm_auction(a)
      display_auction(a)
      print 'Does this look like your auction? (y\n) >> '
      confirm = get_user_input
      if confirm.downcase.chr == 'y'
        true
      else
        false
      end
    end

    def prompt_url
      puts
      puts "Enter an ebay auction url (or 'exit' to exit): "
      print "\n>> "
      url = get_user_input

      url.chomp
    end

    def get_user_input
      s = gets
      exit if 'exit' == s.chomp.downcase
      s
    end
  end

end
