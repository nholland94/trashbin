require 'spec_helper'

describe Sub do
  it "has a valid factory" do
    FactoryGirl.create(:sub).should be_valid
  end

  it "must have a name and moderator" do
    FactoryGirl.build(:sub, :name => nil).should_not be_valid
    FactoryGirl.build(:sub, :moderator_id => nil).should_not be_valid
  end

  it "#moderator returns the user object of the sub moderator" do
    user = FactoryGirl.create(:user)
    other_user = FactoryGirl.create(:user)
    sub = FactoryGirl.build(:sub, :name => "funny", :moderator_id => user.id)
    sub.moderator.should eq user
    sub.moderator.should_not eq other_user
  end

  it { should have_many(:links).through(:link_subs)}

end
