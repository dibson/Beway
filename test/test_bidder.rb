require_relative '../lib/beway/bidder'

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
      bidder.logged_in.should be_true
    end
  end
end
