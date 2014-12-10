require 'spec_helper'
require 'vcr'

describe OAuth do
  let(:stored_token) { {"access_token"=>"ya29.YXJIwThKBwwyJGTJTcLnfeNEGiGi3npeffzzVO6JrPKrc6mPpubmD1M2ojt", "token_type"=>"Bearer", "expires_at"=>1418159416, "refresh_token"=>"1/daSrFubmD1Mm3pTBhJb6T0FLaLBZhxggaUdIsXkfL9BiHv"} }
  let(:oauth)   { Gaah::OAuth.new(stored_token) }
  
  before do
    VCR.configure do |c|
      c.cassette_library_dir = File.dirname(__FILE__) + '/../fixtures/vcr_cassettes' #
      c.hook_into :webmock
    end
  end

  describe '#initialize' do
    before { Gaah::OAuth.setup_oauth2("123", "456", "http://localhost:3012/oauth")}
    
    subject { oauth }

    describe :access_token do

      it 'should return the current access token' do
        oauth.access_token.should == 'ya29.YXJIwThKBwwyJGTJTcLnfeNEGiGi3npeffzzVO6JrPKrc6mPpubmD1M2ojt'
      end

    end
    
    describe :expired? do
    
      it 'should be expired' do
        oauth.expired?.should be_true
      end
      
    end
    
    describe :storable_token do
      
      it 'should return a token storable in a database' do
        oauth.storable_token.should == {"access_token"=>"ya29.YXJIwThKBwwyJGTJTcLnfeNEGiGi3npeffzzVO6JrPKrc6mPpubmD1M2ojt", "token_type"=>"Bearer", "expires_at"=>1418159416, "refresh_token"=>"1/daSrFubmD1Mm3pTBhJb6T0FLaLBZhxggaUdIsXkfL9BiHv"}
      end
    
    end
    
    describe :expires_at do
      
      it 'should return expiration date for the token' do
        oauth.expires_at.should == Time.at(1418159416)
      end
      
    end
    
    describe :authorization_uri do
      
      it 'should return an authorization uri for OAuth2 handshake' do
        oauth.authorization_uri.should == Addressable::URI.parse('https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=123&redirect_uri=http://localhost:3012/oauth&response_type=code&scope=https://apps-apis.google.com/a/feeds/calendar/resource/%20https://www.googleapis.com/auth/calendar%20https://www.googleapis.com/auth/calendar.readonly%20https://www.googleapis.com/auth/admin.directory.user%20https://www.googleapis.com/auth/admin.directory.user.readonly')
      end
      
    end
    
    describe :access_code do
      
      it 'should produce a valid access token' do
        VCR.use_cassette('oauth_fetch_access_token') do
          oauth.access_code= "4/BJDo34MIi_nX9QZV5ZoEjy5Zh4kFlF1psqZ8eYbHY2c.cgtV-9ypD9oQEnp6UAPFm0Hm6uhjlAI"
        end
      end
      
    end
    
  end
end
