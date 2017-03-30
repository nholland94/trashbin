class User < SQLObject
  set_table_name "users"
  my_attr_accessible :username, :email, :password

  # has_many :posts
end