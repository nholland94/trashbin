require 'spec_helper'

describe LinkSub do
  it "has a valid factory" do
    FactoryGirl.create(:link_sub).should be_valid
  end


end
