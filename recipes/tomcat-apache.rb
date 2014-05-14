#
# Cookbook Name:: gitbucket
# Recipe:: tomcat-apache
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
%w{java-1.7.0-openjdk-devel}.each do |pkg|
    package pkg do
    action :install
  end
end

download_tomcat_apache_file = "#{Chef::Config[:file_cache_path]}/#{File.basename(node.apache_tomcat.source)}"
remote_file download_tomcat_apache_file do
  source node[:apache_tomcat][:source]
  owner 'root'
  group 'root'
  mode  '0644'
  not_if { FileTest.file? download_tomcat_apache_file }
end

download_gitbucket_file = "#{Chef::Config[:file_cache_path]}/#{File.basename(node.gitbucket.source)}"
remote_file download_gitbucket_file do
  source node[:gitbucket][:source]
  owner 'root'
  group 'root'
  mode  '0644'
  not_if { FileTest.file? download_gitbucket_file }
end

download_jenkins_file = "#{Chef::Config[:file_cache_path]}/#{File.basename(node.jenkins.source)}"
remote_file download_jenkins_file do
  source node[:jenkins][:source]
  owner 'root'
  group 'root'
  mode  '0644'
  not_if { FileTest.file? download_jenkins_file }
end

user "tomcat" do
  home "/usr/local/tomcat/"
  shell "/bin/bash"
end

group "tomcat" do
  members ['tomcat']
  action :create
end

directory "/usr/local/tomcat/" do
  owner "tomcat"
  group "tomcat"
  mode "0755"
  action :create
end

file '/etc/profile' do
  _file = Chef::Util::FileEdit.new(path)
  _file.insert_line_if_no_match("export TOMCAT_HOME", "\nexport TOMCAT_HOME=/usr/local/tomcat\nexport CATALINA_HOME=/usr/local/tomcat\nexport CLASSPATH=${CLASSPATH}:${CATALINA_HOME}/lib\n")
  content _file.send(:contents).join
  action :create
end

template "tomcat" do
  not_if { File.exists?("/etc/rc.d/init.d/tomcat") }
  path "/etc/rc.d/init.d/tomcat"
  source "tomcat.erb"
  owner "root"
  group "root"
  mode "0755"
end

script "install tomcat_apache" do
  interpreter "bash"
  user "root"
  cwd "#{Chef::Config[:file_cache_path]}"
  not_if { File.exists? "/usr/local/tomcat/webapps" }
  code <<-EOL
    tar zxvf #{File.basename(node.apache_tomcat.source)}
    mv #{Chef::Config[:file_cache_path]}/#{File.basename(node.apache_tomcat.source, '.tar.gz')}/* /usr/local/tomcat
    chown -R tomcat. /usr/local/tomcat/
  EOL
end

script "put gitbucket" do
  interpreter "bash"
  user "root"
  cwd "/usr/local/tomcat"
  not_if { File.exists? "/usr/local/tomcat/webapps/gitbucket" }
  code <<-EOL
    cp -p #{Chef::Config[:file_cache_path]}/#{File.basename(node.gitbucket.source)} ./webapps/
  EOL
end

script "put jenkins" do
  interpreter "bash"
  user "root"
  cwd "/usr/local/tomcat"
  code <<-EOL
    cp -p #{Chef::Config[:file_cache_path]}/#{File.basename(node.jenkins.source)} ./webapps/
  EOL
end

service "tomcat" do
  supports :start => true, :restart => true
  action [ :enable, :start ]
end
