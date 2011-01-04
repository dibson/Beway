require_relative '../lib/beway/bidder'
require_relative './config'

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
        puts "\n" + "*" * 78
        puts "Did you set your username and password in test/config.rb?"
        puts "You should do so to get this test to pass"
        puts "*" * 78
      end
      bidder.logged_in.should be_true
    end
  end
end
