require 'spec_helper'
include Gaah::Calendar

describe Event do
  let(:xml)    { fixture('calendar.xml') }
  let(:events) { Nokogiri::XML(xml)/:entry }
  let(:event)  { Event.new(events.first) }

  describe '#initialize' do
    it 'parses ID' do
      event.id.should == 'http://www.google.com/calendar/feeds/bobert%40example.com/events/n9ommrehhjm5dc6q89ofkm3f8g'
    end

    it 'parses published time' do
      event.published.should == Time.parse('2013-03-25T16:49:48.000Z')
    end

    it 'parses updated time' do
      event.updated.should == Time.parse('2013-03-25T17:03:10.000Z')
    end

    it 'parses title' do
      event.title.should == 'MomCorp'
    end

    it 'parses content' do
      event.content.should == ''
    end

    it 'parses status' do
      event.status.should == 'confirmed'
    end

    describe :who do
      let(:who) { event.who }

      it 'parses who' do
        who.length.should == 2
        who.first.should be_an_instance_of(Gaah::Calendar::Who)
      end

      it 'parses name' do
        who.first.name.should == 'Bobert Jones'
      end

      it 'parses email' do
        who.first.email.should == 'bobert@example.com'
      end
    end

    describe :when do
      let(:_when) { event.when }

      it 'parses when' do
        _when.should be_an_instance_of(When)
      end

      it 'parses start_time' do
        _when.start_time.should == Time.parse('2013-04-01 10:00:00 -0700')
      end

      it 'parses end_time' do
        _when.end_time.should == Time.parse('2013-04-01 11:00:00 -0700')
      end
    end

    it 'parses where' do
      event.where.should == ''
    end

    describe :author do
      let(:author) { event.author }

      it 'parses email' do
        author.email.should == "bobert@example.com"
      end

      it 'parses name' do
        author.name.should == "Bobert Jones"
      end
    end

    it 'parses transparency' do
      event.transparency.should == 'opaque'
    end

    it 'parses visibility' do
      event.visibility.should == 'default'
    end
  end

  describe '.batch_create' do
    let(:processed_events) { Event.batch_create(events) }

    it 'parses events' do
      processed_events.count.should == 10
    end
  end
end
