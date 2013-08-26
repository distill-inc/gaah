require 'spec_helper'
include Gaah::Calendar

describe Event do
  let(:xml)    { fixture('calendar.xml') }
  let(:json)   { fixture('calendar.json') }
  #let(:events) { Nokogiri::XML(xml)/:entry }
  let(:events) { JSON.load(json)['items'] }
  let(:event)  { Event.new(events.first) }

  describe '#initialize' do
    subject { event }
    it 'parses ID' do
      subject.id.should == 'one'
    end

    it 'parses updated time' do
      subject.updated.should == Time.parse('2012-12-13 22:00:00 UTC')
    end

    it 'parses summary' do
      subject.summary.should == 'Holiday Dinner'
    end

    it 'parses description' do
      subject.description.should == 'Holiday party time!'
    end

    describe :attendees do
      let(:subject) { event.attendees }

      it 'parses all attendees' do
        subject.length.should == 3
      end

      it 'parses Who object' do
        subject.first.should be_an_instance_of(Gaah::Calendar::Who)
      end

      it 'parses name' do
        subject.first.name.should == "Bob-Bob O'Bob"
      end

      it 'parses email' do
        subject.first.email.should == 'bob@example.com'
      end
    end

    describe :when do
      let(:subject) { event.when }

      it { should be_an_instance_of(When) }

      it 'parses start_time' do
        subject.start_time.should == Time.parse('2012-12-14 18:30:00 -0800')
      end

      it 'parses end_time' do
        subject.end_time.should == Time.parse('2012-12-14 21:30:00 -0800')
      end
    end

    it 'parses location' do
      subject.location.should == "Prospect, 300 Spear St, San Francisco, CA 94105"
    end

    describe :author do
      let(:author) { event.author }

      it 'parses email' do
        author.email.should == "alice@example.com"
      end

      it 'parses name' do
        author.name.should == "Alice McAlice"
      end
    end

    it 'parses transparency' do
      subject.transparency.should == ''
    end

    it 'parses visibility' do
      subject.visibility.should == 'private'
    end
  end

  describe '.batch_create' do
    let(:subject) { Event.batch_create(events) }
    it { subject.count.should == 3 }
  end
end
