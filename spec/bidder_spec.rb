require_relative '../lib/beway/bidder'

begin
  require_relative './config'
rescue LoadError => e
  puts
  puts "*" * 78
  puts "This spec tests an eBay login.  Please copy the config.rb-dist file:"
  puts
  puts "  cp spec/config.rb-dist spec/config.rb"
  puts
  puts "and edit it with valid ebay credentials."
  puts "*" * 78
  puts
  exit
end

describe Beway::Bidder do

  describe "with invalid login credentials" do
    it "should fail to login" do
      bidder = Beway::Bidder.new('bogus', 'user')
      bidder.logged_in.should be_false
      bidder.login
      bidder.logged_in.should be_false
    end
  end

  describe "with valid login credentials" do
    it "should successfully login" do
      bidder = Beway::Bidder.new(VALID_CREDS[:username], VALID_CREDS[:password])
      bidder.logged_in.should be_false
      bidder.login

      if not bidder.logged_in
        puts
        puts "*" * 78
        puts "Did you set your username and password in test/config.rb?"
        puts "The test should pass if the login credentials are valid."
        puts "*" * 78
        puts
      end
      bidder.logged_in.should be_true
    end
  end
end
