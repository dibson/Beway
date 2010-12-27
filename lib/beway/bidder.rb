require 'mechanize'

module Beway
  
  class BidderError < StandardError; end;

  # Bidder
  #
  # Wrapper for Mechanize to perform actions on ebay
  class Bidder

    EBAY_HOME = 'http://www.ebay.com'

    attr_accessor :username
    attr_writer :password
    attr_reader :agent, :logged_in, :last_login_time

    # create a bidder with login credentials
    def initialize(username, password)
      @username = username
      @password = password
      @agent = Mechanize.new
      @logged_in = false
      @last_login_time = nil
    end

    # log user in with credentials.
    # returns boolean representing success
    def login
      ebay_home_page = @agent.get(EBAY_HOME)

      sign_in_link = ebay_home_page.link_with( :text => 'Sign in' )
      raise BidderError, "Couldn't find sign in link" unless sign_in_link
      login_page = sign_in_link.click

      handle_login_page(login_page)

      return @logged_in
    end

    # bid amount on given auction
    def bid(auction_url, amount)
      login unless @logged_in

      auction_page = @agent.get(auction_url)

      forms = auction_page.forms_with( :action => /http:\/\/offer\.ebay\.com\// )
      raise BidderError, "Couldn't find auction bid form" if forms.length != 1
      bid_form = forms[0]

      bid_form.maxbid = amount
      bid_response = bid_form.submit

      if is_login_page?(bid_response)
        bid_response = handle_login_page(bid_response) 
      end

      forms = bid_response.forms_with( :action => 'http://offer.ebay.com/ws/eBayISAPI.dll' )
      raise BidderError, "Couldn't find confirm bid form" if forms.length != 1
      confirm_form = forms[0]
      confirm_button = confirm_form.button_with( :value => 'Confirm Bid' )
      raise BidderError, "Couldn't find confirm button" unless confirm_button

      confirm_response = confirm_form.submit( confirm_button )
      confirm_response
    end

    private

    # is page a login page?
    def is_login_page?(page)
      if page.form_with( :name => 'SignInForm')
        true
      else
        false
      end
    end

    # log into ebay as prompted by login_page
    def handle_login_page(login_page)
      login_form = login_page.form_with( :name => 'SignInForm')
      raise BidderError, "Couldn't find login form" unless login_form
      login_form.userid = @username
      login_form.pass = @password
      login_response =  login_form.submit

      @logged_in = login_response.search('form#SignInForm').empty?
      @last_login_time = Time.now if @logged_in

      return login_response
    end

  end
end
