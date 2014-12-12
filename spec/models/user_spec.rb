require 'spec_helper'
include Gaah::Directory

describe User do
  let(:json)   { fixture('users.json') }
  let(:users) { JSON.load(json)['users'] }
  let(:user)  { User.new(users.first) }

  describe '#initialize' do
    it 'parses ID' do
      user.id.should == '123823548234723423423'
    end

    it 'parses suspended' do
      user.suspended.should == false
    end

    it 'parses admin' do
      user.admin.should == false
    end

    it 'parses user_name' do
      user.user_name.should == 'boom@gild.com'
    end

    it 'parses email' do
      user.user_name.should == 'boom@gild.com'
    end

    it 'parses name' do
      user.name.should == 'Boom Bastic'
    end
  end
end
