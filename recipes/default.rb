#
# Cookbook:: tomcat_refactor
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

package 'java-1.7.0-openjdk-devel'

directory '/opt/tomcat' do
 action :create
end

group 'tomcat' do
  append true
end

user 'tomcat' do
  group 'tomcat'
  home '/opt/tomcat'
  shell '/bin/nologin'
  manage_home false
end

include_recipe "tar::default"

tar_extract 'http://supergsego.com/apache/tomcat/tomcat-8/v8.5.23/bin/apache-tomcat-8.5.23.tar.gz' do
  action :extract
  target_dir '/opt/tomcat'
  creates '/opt/tomcat/lib'
  tar_flags [ '-P', '--strip-components 1' ]
end

#include_recipe "fileutils::default"

fileutils '/opt/tomcat' do
  recursive true
  group 'tomcat'
end

fileutils '/opt/tomcat/conf' do
  recursive true
  file_mode ['g+r']
  directory_mode ['g+r']
end

directory 'opt/tomcat/conf' do
  mode '0750'
end

changeOwnerDirectories = [ '/opt/tomcat/work/', '/opt/tomcat/logs/', '/opt/tomcat/temp/', '/opt/tomcat/webapps' ]

changeOwnerDirectories.each do |dir|
  fileutils dir do
    recursive true
    owner 'tomcat'
  end
end

template '/etc/systemd/system/tomcat.service' do
  source 'systemd.erb'
end

execute 'daemon reload' do
  command 'systemctl daemon-reload'
end

service 'tomcat' do
  action [:start, :enable]
end



