require 'spec_helper.rb'


describe "the goal creation process" do

  it "requires a logged in user" do
    sign_out
    visit "/goals/new"
    expect(page).to have_content "Sign In"
  end

  before(:each) do
    sign_up_with_user_test
  end

  it "has a goal creation page" do
    visit "/goals/new"
    expect(page).to have_content "Create Goal"
  end

  describe "requires all attributes" do

    it "requires goal title" do
      visit "/goals/new"
      fill_in "goal_body", :with => "some stuff"
      choose("goal_is_private_false")
      click_button "Create Goal"
      expect(page).to have_content "Create Goal"
    end

    it "requires goal body" do
      visit "/goals/new"
      fill_in "goal_title", :with => "my goal"
      choose("goal_is_private_false")
      click_button "Create Goal"
      expect(page).to have_content "Create Goal"
    end

    it "requires a goal type selection" do
      visit "/goals/new"
      fill_in "goal_title", :with => "my goal"
      fill_in "goal_body", :with => "some stuff"
      click_button "Create Goal"
      expect(page).to have_content "Create Goal"
    end

  end

  it "creates a goal" do
    create_goal("my goal", "user")
    expect(page).to have_content "my goal"
  end

end

describe "viewing all goals" do

  it "has content 'All Goals'" do
    visit "/goals"
    expect(page).to have_content "All Goals"
  end

  it "displays a goal" do
    create_goal("goal 1", "user")
    visit "/goals"
    expect(page).to have_content "goal 1"
  end

  it "displays many goals" do
    create_goal("goal 1", "user")
    create_goal("goal 2", "user")
    create_goal("goal 3", "user")
    visit "/goals"
    expect(page).to have_content "goal 1"
    expect(page).to have_content "goal 2"
    expect(page).to have_content "goal 3"
  end

  before(:each) do
    create_goal("private goal", "user1", "true")
  end

  it "should not be able to see private goals you don't own" do
    sign_out
    sign_up("user2")
    expect(page).not_to have_content "private goal"
  end

  it "should be able to see private goals you own" do
    visit "/goals"
    expect(page).to have_content "private goal"
  end

end

describe "viewing individual goals" do

  it "should be able to see any public goal" do
    create_goal("goal 1", "user1")
    sign_out
    sign_up("user2")
    visit "/goals/1"
    expect(page).to have_content "goal 1"
  end

  before(:each) do
    create_goal("goal 1", "user1", "true")
  end

  it "should not be able to view private goals you don't own" do
    sign_out
    sign_up("user2")
    visit "/goals/1"
    expect(page).not_to have_content "goal 1"
  end

  it "should be able to view private goals you own" do
    expect(page).to have_content "goal 1"
  end

end

describe "the goal update process" do

  before(:each) do
    create_goal("goal 1", "user1")
  end

  it "only the goal creator can edit the goal" do
    sign_out
    sign_up("user2")

    visit "/goals/1/edit"
    expect(page).to have_content "All Goals"
  end

  it "starts with forms filled with old data" do
    visit "/goals/1/edit"
    expect(find_field("goal_title").value).to eq "goal 1"
  end

  it "saves the information" do
    visit "/goals/1/edit"
    fill_in "goal_title", :with => "goal 2"
    click_button "Update Goal"
    expect(page).to have_content "goal 2"
  end

end

describe "the goal deletion process" do

  before(:each) do
    create_goal("goal 1", "user1")
  end

  it "only the goal create can delete the goal" do
    sign_out
    sign_up("user2")

    visit "/goals/1"
    expect(page).not_to have_button "Delete"
  end

  it "has a delete button for goal creator" do
    expect(page).to have_button "Delete"
  end

  it "redirects to goal index" do
    click_button "Delete"
    expect(page).to have_content "All Goals"
  end

  it "actually deletes from database" do
    click_button "Delete"
    expect(page).not_to have_content "goal 1"
  end

end