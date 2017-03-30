#
# Cookbook Name:: iis_demo
# Recipe:: default
#
# Copyright 2014, Nathan Holland
#
# All rights reserved - Do Not Redistribute
#

powershell_script 'Install IIS' do
  code 'add-windowsfeature Web-Server'
  action :run
end

service 'w3svc' do
  action [:enable, :start]
end

countries = data_bag('countries')

template 'C:\inetpub\wwwroot\Default.htm' do
  source 'Default.htm.erb'
  variables countries: countries
end

countries.each do |item|
  country_data = data_bag_item('countries', item)
  country_name = country_data['country']
  capitol_name = country_data['capitol']

  template "C:\\inetpub\\wwwroot\\#{country_name}.htm" do
    source 'countries.htm.erb'
    variables(
      country: country_name,
      capitol: capitol_name
    )
  end
end
