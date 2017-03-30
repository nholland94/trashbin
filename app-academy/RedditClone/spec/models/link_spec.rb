require 'spec_helper'

describe Link do
  it "has a valid factory" do
    FactoryGirl.create(:link).should be_valid
  end

  it "must have a title and url" do
    FactoryGirl.build(:link, :title => nil).should_not be_valid
    FactoryGirl.build(:link, :url => nil).should_not be_valid
  end

  it "can have text or not have text" do
    FactoryGirl.build(:link, :text => nil).should be_valid
    FactoryGirl.build(:link, :text => "sdfgsdfg").should be_valid
  end

  it "should allow various types of valid URLs" do
    FactoryGirl.build(:link, :url => "espn.com").should be_valid
    FactoryGirl.build(:link, :url => "www.espn.com").should be_valid
    FactoryGirl.build(:link, :url => "http://www.espn.com").should be_valid
    FactoryGirl.build(:link, :url => "http://espn.com/nfl").should be_valid
  end

  it "should not allow various types of invalid URLs" do
    FactoryGirl.build(:link, :url => "isdufgids").should_not be_valid
    FactoryGirl.build(:link, :url => "htp://espn.com").should_not be_valid
    FactoryGirl.build(:link, :url => "http://www..espn.com").should_not be_valid
  end

  it { should have_many(:subs).through(:link_subs) }
  it { should belong_to(:user) }

end
