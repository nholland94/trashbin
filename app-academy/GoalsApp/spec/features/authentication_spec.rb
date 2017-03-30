require 'spec_helper'

describe "the signup process" do

  it "has a new user page" do
    visit "/users/new"
    expect(page).to have_content "Sign Up"
  end

  describe "signing up a user" do
    before(:each) do
      visit "/users/new"
      fill_in 'username', :with => "user_test"
      fill_in "password", :with => "biscuits"
      click_on "Sign Up"
    end

    it "redirects to goals index page after signup" do
      expect(page).to have_content "All Goals!"
    end

    it "shows username on the homepage after signup" do
      expect(page).to have_content "user_test"
    end

  end
end

describe "logging in" do

  before(:each) do
    sign_up_with_user_test
  end

  it "shows username on the homepage after login" do
    expect(page).to have_content "user_test"
  end

end

describe "logging out" do


  it "begins with logged out state" do
    visit "/goals"
    expect(page).to have_button "Sign In"
  end


  it "doesn't show username on the homepage after logout" do
    sign_up_with_user_test
    click_on "Sign Out"
    expect(page).not_to have_content "test_user"
  end

end


