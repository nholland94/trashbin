require 'spec_helper'

describe User do
  it "has a valid factory" do
    FactoryGirl.create(:user).should be_valid
  end

  it "must have a username and password" do
    FactoryGirl.build(:user, :username => nil).should_not be_valid
    FactoryGirl.build(:user, :password => "").should_not be_valid
  end

  it "must have a password that is at least 6 characters long" do
    FactoryGirl.build(:user, :password => "yo").should_not be_valid
    FactoryGirl.build(:user, :password => "yoyoyo").should be_valid
  end

  it "rejects a username that already exists in the database" do
    FactoryGirl.create(:user, :username => "whatup")
    FactoryGirl.build(:user, :username => "whatup").should_not be_valid
  end

  it "will auto-create a session token if nil" do
    FactoryGirl.build(:user, :session_token => nil).should be_valid
  end

  it { should_not allow_mass_assignment_of(:password_digest) }

  it "User#is_password? accepts only the correct password" do
    u = FactoryGirl.create(:user, :username => "whatup", :password => "whatup")
    u.is_password?("whatup").should be_true
    u.is_password?("safsdargsd").should_not be_true
  end

  it "does not store the user's password" do
    user_instance = FactoryGirl.create(:user, :username => "whatup",
      :password => "whatup")
    u = User.find(user_instance.id)
    u.password.should be_nil
  end

  it "finds users using User::find_by_credentials" do
    u = FactoryGirl.create(:user, :username => "whatup", :password => "whatup")
    User.find_by_credentials("whatup", "whatup").should eq u
    User.find_by_credentials("whatup", "dkdfafs").should be_nil
    User.find_by_credentials("dafsdfaf", "whatup").should be_nil
  end

  it "resets the session token" do
    u = FactoryGirl.create(:user)
    token = u.session_token
    u.reset_session_token!
    token.should_not eq u.session_token
  end

  it { should have_many(:subs) }
  it { should have_many(:links) }

  #it { should have_many(:links) }
end
