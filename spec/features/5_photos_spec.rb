require "rails_helper"

show_tests_in_browser = true
do_not_show_tests_in_browser = false

feature "Photos:", js: do_not_show_tests_in_browser do

  scenario "in /photos, Bootstrap panels used", points: 1 do
    user = FactoryGirl.create(:user)
    photo = FactoryGirl.create(:photo, :user_id => user.id)
    login_as(user, :scope => :user)

    visit "/photos"

    expect(page).to have_css(".panel")
  end

  scenario "in /photos, Font Awesome fa-plus icon used (and 'Photos' h1 tag isn't)", points: 1 do
    user = FactoryGirl.create(:user)
    photo = FactoryGirl.create(:photo, :user_id => user.id)
    login_as(user, :scope => :user)

    visit "/photos"

    expect(page).to have_css(".fa-plus")
    expect(page).not_to have_selector("h1", text: "Photos")
  end

  scenario "/photos displays per-photo username, photo, and time elapsed", points: 1, hint: "Time elapsed ends in 'ago' (e.g., '5 months ago')." do
    user_1 = FactoryGirl.create(:user, :username => "user_1", :email => "1@m.com")
    user_2 = FactoryGirl.create(:user, :username => "user_2", :email => "2@m.com")
    user_3 = FactoryGirl.create(:user, :username => "Three", :email => "three@m.com")
    photo_1 = FactoryGirl.create(:photo, :user_id => user_1.id)
    photo_2 = FactoryGirl.create(:photo, :user_id => user_2.id)
    login_as(user_3, :scope => :user)

    visit "/photos"

    expect(page).to have_content("#{photo_1.user.username}")
    expect(page).to have_css("img[src*='#{photo_1.image}']")
    expect(page).to have_content("#{photo_2.user.username}")
    expect(page).to have_css("img[src*='#{photo_2.image}']")
    expect(page).to have_content("ago")
  end

  scenario "header uses Font Awesome fa-sign-out icon", points: 1 do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)

    visit "/photos"

    within("nav") {
      expect(page).to have_css(".fa-sign-out")
    }
  end

  scenario "/photos lists comments with authors", points: 1 do
    user_1 = FactoryGirl.create(:user, :username => "1", :email => "1@m.com")
    user_2 = FactoryGirl.create(:user, :username => "2", :email => "2@m.com")
    user_3 = FactoryGirl.create(:user, :username => "Three", :email => "three@m.com")
    photo_1 = FactoryGirl.create(:photo, :user_id => user_3.id)
    photo_2 = FactoryGirl.create(:photo, :user_id => user_3.id)
    photo_3 = FactoryGirl.create(:photo, :user_id => user_3.id)
    comment_1 = FactoryGirl.create(:comment, :user_id => user_1.id, :body => "comment_1", :photo_id => photo_1.id)
    comment_2 = FactoryGirl.create(:comment, :user_id => user_2.id, :body => "comment_two", :photo_id => photo_3.id)
    login_as(user_3, :scope => :user)

    visit "/photos"

    expect(page).to have_content(comment_1.body)
    expect(page).to have_content(comment_1.user.username)
    expect(page).to have_content(comment_2.body)
    expect(page).to have_content(comment_2.user.username)
  end

  scenario "/photos shows Font Awesome heart icons to add/delete likes", points: 1, hint: "Font Awesome icon classes: fa-heart and fa-heart-o." do
    user_1 = FactoryGirl.create(:user, :username => "1", :email => "1@m.com")
    user_2 = FactoryGirl.create(:user, :username => "2", :email => "2@m.com")
    photo_1 = FactoryGirl.create(:photo, :user_id => user_2.id)
    photo_2 = FactoryGirl.create(:photo, :user_id => user_2.id)
    like_1 = FactoryGirl.create(:like, :user_id => user_1.id, :photo_id => photo_1.id)
    like_2 = FactoryGirl.create(:like, :user_id => user_2.id, :photo_id => photo_2.id)
    login_as(user_1, :scope => :user)

    visit "/photos"

    expect(page).to have_css(".fa-heart")
    expect(page).to have_css(".fa-heart-o")
  end

  scenario "/photos includes form field with placeholder 'Add a comment...'", points: 1 do
    user = FactoryGirl.create(:user, :username => "1", :email => "1@m.com")
    photo = FactoryGirl.create(:photo, :user_id => user.id)
    login_as(user, :scope => :user)

    visit "/photos"

    expect(page).to have_selector("input[placeholder='Add a comment...']")
  end
end
