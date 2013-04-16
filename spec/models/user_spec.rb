require 'spec_helper'
include Gaah::Provisioning

describe User do
  let(:xml)   { fixture('provisioning.xml') }
  let(:users) { Nokogiri::XML(xml)/:entry }
  let(:user)  { User.new(users.first) }

  describe '#initialize' do
    it 'parses ID' do
      user.id.should == 'https://apps-apis.google.com/a/feeds/example.com/user/2.0/fry'
    end

    it 'parses suspended' do
      user.suspended.should == false
    end

    it 'parses admin' do
      user.admin.should == false
    end

    it 'parses title' do
      user.title.should == 'fry'
    end

    it 'parses user_name' do
      user.user_name.should == 'fry'
    end

    it 'parses name' do
      user.name.should == 'Philip Fry'
    end
  end
end
