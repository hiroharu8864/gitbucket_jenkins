#
# Cookbook Name:: gitbucket
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
# Disable iptables
service "iptables" do
  action [ :disable, :stop ]
end

%w{gcc gcc-c++}.each do |pkg|
  package pkg do
    action :install
  end
end

execute "yum-update" do
  user "root"
  command "/usr/bin/yum -y update"
  action :run
end
