require "rails_helper"

show_tests_in_browser = true
do_not_show_tests_in_browser = false

feature "Photos:", js: do_not_show_tests_in_browser do

  scenario "only the owner can see the edit button", points: 2, hint: "Use an 'if' statement in the view template" do
    alice = create :user, username: "alice", email: "alice@example.com"
    bob = create :user, username: "bob", email: "bob@example.com"

    alices_photo = create :photo, user_id: alice.id
    bobs_photo = create :photo, user_id: bob.id

    login_as bob, scope: :user

    visit "/photos/#{alices_photo.id}"
    expect(page).not_to have_link("Edit")

    visit "/photos/#{bobs_photo.id}"
    expect(page).to have_link("Edit")
  end

  scenario "only the owner can see the delete button", points: 2, hint: "Use an 'if' statement in the view template" do
    alice = create :user, username: "alice", email: "alice@example.com"
    bob = create :user, username: "bob", email: "bob@example.com"
    alices_photo = create :photo, user_id: alice.id
    bobs_photo = create :photo, user_id: bob.id
    login_as(bob, scope: :user)

    visit "/photos/#{alices_photo.id}"
    expect(page).not_to have_link(nil, href: "/delete_photo/#{alices_photo.id}")

    visit "/photos/#{bobs_photo.id}"
    expect(page).to have_link(nil, href: "/delete_photo/#{bobs_photo.id}")
  end

  scenario "Bootstrap panels used on index page", points: 1 do
    user = create :user
    photo = create :photo, user_id: user.id
    login_as(user, scope: :user)

    visit "/photos"

    expect(page).to have_css(".panel")
  end

  scenario "Font Awesome fa-plus icon used in add photo button on index page", points: 1 do
    user = create :user
    photo = create :photo, user_id: user.id
    login_as(user, scope: :user)

    visit "/photos"

    expect(page).to have_css(".fa-plus")
  end

  scenario "/photos displays per-photo username, photo, and time elapsed", points: 1, hint: "Time elapsed ends in 'ago' (e.g., '5 months ago')." do
    alice = create :user, :username => "alice", :email => "1@m.com"
    bob = create :user, :username => "bob", :email => "2@m.com"
    user_3 = create :user, :username => "Three", :email => "three@m.com"
    alices_photo = create :photo, user_id: alice.id
    bobs_photo = create :photo, user_id: bob.id
    login_as(user_3, scope: :user)

    visit "/photos"

    expect(page).to have_content("#{alices_photo.user.username}")
    expect(page).to have_css("img[src*='#{alices_photo.image}']")
    expect(page).to have_content("#{bobs_photo.user.username}")
    expect(page).to have_css("img[src*='#{bobs_photo.image}']")
    expect(page).to have_content("ago")
  end

  scenario "header uses Font Awesome fa-sign-out icon", points: 1 do
    user = create :user
    login_as(user, scope: :user)

    visit "/photos"

    within("nav") {
      expect(page).to have_css(".fa-sign-out")
    }
  end

  scenario "/photos lists comments with authors", points: 1 do
    alice = create :user, username: "alice", email: "alice@example.com"
    bob = create :user, username: "bob", email: "bob@example.com"
    user_3 = create :user, :username => "Three", :email => "three@m.com"
    alices_photo = create :photo, user_id: user_3.id
    bobs_photo = create :photo, user_id: user_3.id
    photo_3 = create :photo, user_id: user_3.id
    comment_1 = create :comment, user_id: alice.id, :body => "comment_1", :photo_id => alices_photo.id
    comment_2 = create :comment, user_id: bob.id, :body => "comment_two", :photo_id => photo_3.id
    login_as(user_3, scope: :user)

    visit "/photos"

    expect(page).to have_content(comment_1.body)
    expect(page).to have_content(comment_1.user.username)
    expect(page).to have_content(comment_2.body)
    expect(page).to have_content(comment_2.user.username)
  end

  scenario "/photos shows Font Awesome heart icons to add/delete likes", points: 1, hint: "Font Awesome icon classes: fa-heart and fa-heart-o." do
    alice = create :user, username: "alice", email: "alice@example.com"
    bob = create :user, username: "bob", email: "bob@example.com"
    alices_photo = create :photo, user_id: bob.id
    bobs_photo = create :photo, user_id: bob.id
    like_1 = create :like, user_id: alice.id, :photo_id => alices_photo.id
    like_2 = create :like, user_id: bob.id, :photo_id => bobs_photo.id
    login_as(alice, scope: :user)

    visit "/photos"

    expect(page).to have_css(".fa-heart")
    expect(page).to have_css(".fa-heart-o")
  end

  scenario "/photos includes form field with placeholder 'Add a comment...'", points: 1 do
    user = create :user, username: "alice", email: "alice@example.com"
    photo = create :photo, user_id: user.id
    login_as(user, scope: :user)

    visit "/photos"

    expect(page).to have_selector("input[placeholder='Add a comment...']")
  end
end

feature "Photos:", js: show_tests_in_browser do

  scenario "quick-add a comment works and leads back to /photos", points: 2 do
    alice = create :user, username: "alice", email: "alice@example.com"
    bob = create :user, :username => "bob", :email => "two@m.com"
    photo = create :photo, user_id: alice.id
    login_as(bob, scope: :user)

    visit "/photos"
    new_comment = "Just added a comment at #{Time.now.to_f}"
    fill_in("Add a comment...", with: new_comment)
    find_field("Add a comment...").native.send_keys(:return)

    expect(page).to have_content(new_comment)
    expect(page).to have_current_path("/photos")
  end

  scenario "quick-add a comment sets the author correctly", points: 1, hint: "Test assumes that each row in /comments lists either the author's ID or username." do
    alice = create :user, username: "alice", email: "alice@example.com"
    bob = create :user, :username => "bob", :email => "two@m.com", :id => "#{Time.now.to_i}"
    photo = create :photo, user_id: alice.id
    login_as(bob, scope: :user)

    visit "/photos"
    new_comment = "Just added a comment at #{Time.now.to_f + Time.now.to_f}"
    fill_in("Add a comment...", with: new_comment)
    find_field("Add a comment...").native.send_keys(:return)
    visit "/comments"

    expect(page).to have_content(new_comment)
    within('tr', text: new_comment) do
      if page.has_content?(bob.id)
        expect(page).to have_content(bob.id)
      else
        expect(page).to have_content(bob.username)
      end
    end
  end

  scenario "quick-add a like works in /photos", points: 2 do
    user = create :user, username: "alice", email: "alice@example.com"
    photo = create :photo, user_id: user.id
    login_as(user, scope: :user)

    visit "/photos"
    find(".fa-heart-o").click

    expect(page).to have_css(".fa-heart")
  end

  scenario "quick-delete a like works in /photos", points: 1 do
    user = create :user
    photo = create :photo, user_id: user.id
    like = create :like, user_id: user.id, :photo_id => photo.id
    login_as(user, scope: :user)

    visit "/photos"

    if page.has_link?(nil, href: "/delete_like/#{like.id}")
      expect(page).to have_css(".fa-heart")
      expect(page).to have_link(nil, href: "/delete_like/#{like.id}")
    else
      find(".fa-heart").click
      expect(page).to have_css(".fa-heart-o")
    end
  end

end
