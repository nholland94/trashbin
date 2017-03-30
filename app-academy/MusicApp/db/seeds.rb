# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(email: "jacob@gmail.com", password: "baller420", activated: true, admin: true)
User.create(email: "duckface@comcast.net", password: "duckling", activated: true)
User.create(email: "coolkyle@yahoo.com", password: "testing", activated: true)
User.create(email: "steve@hotmail.com", password: "nothing", activated: true)
User.create(email: "user@email.com", password: "password", activated: true)

Band.create(name: "Smashers of Pumpkins")
Album.create(title: "Pumpkins in the Night", artist_id: 1)
Track.create(title: "Smashing Success", album_id: 1)
Track.create(title: "Holy Pumpkins, Batman", album_id: 1)
Track.create(title: "Pumpkinhead", album_id: 1)
Track.create(title: "For the last time, we are not the Smashing Pumpkins", album_id: 1)
Note.create(body: "spamspamspam", user_id: 3, track_id: 1)
Note.create(body: "A legitimate note", user_id: 4, track_id: 1)