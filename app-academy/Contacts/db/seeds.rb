users = []

100.times do
  p user = User.new({
    name: Faker::Name.name,
    email: Faker::Internet.email
  })

  user.save
  users << user.id
end

num_contacts = 0

users.each do |id|
  (rand(50) + 50).times do
    p Contact.new({
      name: Faker::Name.name,
      email: Faker::Internet.email,
      user_id: id
    }).save

    num_contacts += 1
  end
end

id_pairs_done = []

300.times do
  c_id = rand(num_contacts) + 1
  u_id = rand(users.length) + 1
  unless id_pairs_done.include?([u_id, c_id])
    id_pairs_done << [u_id, c_id]
    p ContactShare.new({
      contact_id: c_id,
      user_id: u_id
    }).save
  end
end