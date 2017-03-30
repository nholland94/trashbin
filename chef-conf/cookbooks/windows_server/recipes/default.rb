#
# Cookbook Name:: windows_server
# Recipe:: default
#
# Copyright 2014, Nathan Holland
#
# All rights reserved - Do Not Redistribute
#

windows_path 'C:\tmp' do
  action :add
end

windows_task 'chef-client' do
  user 'chef'
  password 'chef'
  command 'chef-client -L C:\tmp\ '
  run_level :highest
  frequency :minute
  frequency_modifier 15
end
