require 'spec_helper'
require 'vcr'

describe Gaah::Directory::Api do
  let(:stored_token) { {"access_token"=>"ya29.YXJIwThKBwwyJGTJTcLnfeNEGiGi3npeffzzVO6JrPKrc6mPpubmD1M2ojt", "token_type"=>"Bearer", "expires_at"=>1418159416, "refresh_token"=>"1/daSrFubmD1Mm3pTBhJb6T0FLaLBZhxggaUdIsXkfL9BiHv"} }
  
  let(:oauth)   { Gaah::OAuth.new(stored_token) }
  
  before do
    VCR.configure do |c|
      c.cassette_library_dir = File.dirname(__FILE__) + '/../fixtures/vcr_cassettes' #
      c.hook_into :webmock
    end
    
    Gaah::OAuth.setup_oauth2("123", "456", "http://localhost:3012/oauth")
  end

  describe :users do
    
    subject do
      VCR.use_cassette('get_users') do
        Gaah::Directory::Api.users(oauth, 'gild.com')
      end
    end
    
    it 'should access a list of 4 users' do
      subject.count.should == 4
    end
    
    it 'should get a first result with Joe Doe' do
      subject.first.name.should == "Joe Doe"
    end
    
    it 'should get a first result with Pinko Pallino' do
      subject.last.name.should == "Pinko Pallino"
    end
    
    describe "with invalid token" do
      subject do
        VCR.use_cassette('get_users_invalid_token') do
          Gaah::Directory::Api.users(oauth, 'gild.com')
        end
      end
      
      it 'should throw an exception' do
        lambda { subject }.should raise_error
      end
    end
    
  end
  
  describe :events do
    
    subject do
      VCR.use_cassette('get_events') do
        
        user = Gaah::Directory::User.new({"id"=>"111211678950890114428", 
                    "primaryEmail"=>"bob@gild.com", "name" => { "givenName" => "Pinko", "familyName" => "Pallino", "fullName" => "Pinko Pallino"}, 
                    "isAdmin" => false, "isDelegatedAdmin" => false, "suspended" => false, "emails" => { "address" => "bob@gild.com", "primary" => true} })
        
        t1 = 1417455819 #a time in the past given the time of the VCR test
        t2 = 1423417432 #a time in the future given the time of the VCR test
        
        user.events(oauth, {time_min: Time.at(t1), time_max: Time.at(t2)})
      end
    end
    
    it 'should return 5 events' do
      subject.count.should == 5
    end
    
    it 'should get a summary of an event' do
      subject.first.summary.should == 'Bob - Frank (lunch?)'
    end
    
    it 'should get time range of an event' do
      subject.first.when.start_time.should == Time.at(1417464000)
      subject.first.when.end_time.should == Time.at(1417467600)
    end
    
  end

end
