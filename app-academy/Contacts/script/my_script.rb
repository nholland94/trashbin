require 'addressable/uri'
require 'rest-client'
require 'json'

url = Addressable::URI.new(
  scheme: 'http',
  host: 'localhost',
  port: 3000,
  path: '/contact_shares/1'
).to_s

begin
  puts RestClient.delete(url)
rescue => e
  p e.response
end

# create_url = Addressable::URI.new(
#   scheme: 'http',
#   host: 'localhost',
#   port: 3000,
#   path: '/users/'
# ).to_s
#
# puts RestClient.post(create_url, {:name => "Bob Dole", :email =>"."})

# contact_create_url = Addressable::URI.new(
#   scheme: 'http',
#   host: 'localhost',
#   port: 3000,
#   path: '/users/2/contacts'
# ).to_s
#
# puts RestClient.post(contact_create_url, :contact => {
#                                          :name => "Abraham Lincoln",
#                                          :email => "logcabin@gmail.com"})

# contact_shared_create_url = Addressable::URI.new(
#   scheme: 'http',
#   host: 'localhost',
#   port: 3000,
#   path: '/contact_shares'
# ).to_s
#
# puts RestClient.post(contact_shared_create_url, :contact_share => {
#                                          :user_id => "2",
#                                          :contact_id => "2"})

# user_update_url = Addressable::URI.new(
#   scheme: 'http',
#   host: 'localhost',
#   port: 3000,
#   path: '/users/1'
# ).to_s
#
# puts RestClient.put(user_update_url, :user => {
#                                               :name => "Bob Dole",
#                                               :email => "newemail@bobdole.com"
#                                               })

# contact_update_url = Addressable::URI.new(
#   scheme: 'http',
#   host: 'localhost',
#   port: 3000,
#   path: '/contacts/2'
# ).to_s
#
# puts RestClient.put(contact_update_url, :contact => {
#                                               :name => "No one",
#                                               :email => "newemail@notemail.com",
#                                               :user_id => "1"
#                                               })

