require 'spec_helper'
require 'vcr'

describe Gaah::Calendar::Api do
  #let(:stored_token) { {"access_token"=>"ya29.YXJIwThKBwwyJGTJTcLnfeNEGiGi3npeffzzVO6JrPKrc6mPpubmD1M2ojt", "token_type"=>"Bearer", "expires_at"=>1418159416, "refresh_token"=>"1/daSrFubmD1Mm3pTBhJb6T0FLaLBZhxggaUdIsXkfL9BiHv"} }
  let(:stored_token) { {"access_token"=>"ya29.2AAwLxIyYohYixBHRzqMGqqSpTdiS0E8JW10qHIng9PHubFdB1xb7TgVrtVGmSeueg0Rwfu5ghxFIA", "token_type"=>"Bearer", "expires_at"=>1418195046, "refresh_token"=>"1/Z_l9N6J0oUdMtH-jhnC7k4jpqeyR8ybIXqgdhxscxFF90RDknAdJa_sgfheVM0XT" } }
  let(:oauth)   { Gaah::OAuth.new(stored_token) }
  
  before do
    VCR.configure do |c|
      c.cassette_library_dir = File.dirname(__FILE__) + '/../fixtures/vcr_cassettes' #
      c.hook_into :webmock
    end
    
    #Gaah::OAuth.setup_oauth2("123", "456", "http://localhost:3012/oauth")
    Gaah.setup_oauth2('399207994460-m6do93hqo3vsmr80jkui8c5fd2bnjkk9.apps.googleusercontent.com', 'd4rWx9nvmaYiU3HfRWgC6HP3', 'http://localhost:3021/oauth2')
    
  end

  describe :calendars do
    
    subject do
      VCR.use_cassette('get_calendars') do
        Gaah::Calendar::Api.calendars(oauth)
      end
    end
    
    it 'should access a list of 3 calendars' do
      subject.count.should == 3
    end
    
    it 'should return id of first calendar' do
      subject.first.id.should == "gild.com_9b06tdhcuddgug1hb7b2kq337s@group.calendar.google.com"
    end
    
    it 'should return description of last calendar' do
      subject.last.description.should == "My Cal"
    end
    
    describe "with invalid token" do
      subject do
        VCR.use_cassette('get_calendars_invalid_token') do
          Gaah::Calendar::Api.calendars(oauth)
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
        t1 = 1417455819 #a time in the past given the time of the VCR test
        t2 = 1423417432 #a time in the future given the time of the VCR test
        
        Gaah::Calendar::Api.events(oauth, {email: 'bob@gild.com', time_min: Time.at(t1), time_max: Time.at(t2)})
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
    
    describe "with invalid token" do
      subject do
        VCR.use_cassette('get_events_invalid_token') do
          t1 = 1417455819 #a time in the past given the time of the VCR test
          t2 = 1423417432 #a time in the future given the time of the VCR test
          
          Gaah::Calendar::Api.events(oauth, {email: 'bob@gild.com', time_min: Time.at(t1), time_max: Time.at(t2)})
        end
      end
      
      it 'should throw an exception' do
        lambda { subject }.should raise_error
      end
    end
        
  end

  describe :create_event do
    subject do
      VCR.use_cassette('create_event') do
    
        options = {
          email:        'bob@gild.com',
          start_time:   Time.at(1418252400),
          end_time:     Time.at(1418257800),
          summary:      "Meeting with Batman",
          description:  "Fight the crime",
          participants: ["francesco@gild.com"],
          resources:    ["gild.com_2d32333339303634362d333933@resource.calendar.google.com"],
        }
      
        Gaah::Calendar::Api.create_event(oauth, options)
      
      end

    end
    
    it 'should create one event in bob calendar with valid summary' do
      subject.summary.should == 'Meeting with Batman'
    end
    
    it 'should create one event in bob calendar with valid description' do
      subject.description.should == 'Fight the crime'
    end
    
    it 'should create one event in bob calendar with valid id' do
      subject.id.should == 'snvqik8vfm9mqg5kt93e3je0ng'
    end
    
  end

  describe :event do
    
    subject do
      VCR.use_cassette('get_event') do
        Gaah::Calendar::Api.event(oauth, { email: 'bob@gild.com', event_id: 'snvqik8vfm9mqg5kt93e3je0ng' })
      end
    end
    
    it 'should get one event in bob calendar with valid summary' do
      subject.summary.should == 'Meeting with Batman'
    end
    
    it 'should get one event in bob calendar with valid description' do
      subject.description.should == 'Fight the crime'
    end
    
    it 'should get one event in bob calendar with valid id' do
      subject.id.should == 'snvqik8vfm9mqg5kt93e3je0ng'
    end
    
  end

  describe :delete_event do
    
    subject do
      VCR.use_cassette('delete_event') do      
        Gaah::Calendar::Api.delete_event(oauth, { email: 'bob@gild.com', event_id: 'snvqik8vfm9mqg5kt93e3je0ng' })
      end
    end
    
    it 'should delete one event in bob calendar with valid summary' do
      subject.should == {:success=>true}
    end
    
    describe :event_not_found do
      
      subject do
        VCR.use_cassette('delete_event_not_found') do      
          Gaah::Calendar::Api.delete_event(oauth, { email: 'bob@gild.com', event_id: 'snvqik8vfm9mqg5kt93e3je0ppp' })
        end
      end
      
      it 'should return event not found' do
        subject.should == {:success=>false, :error=>"Event was not found."}
      end
      
    end
    
  end

end
