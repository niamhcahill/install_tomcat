#
# Cookbook:: install_tomcat
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

#Install OpenJDK 7 JDK
yum_package 'java-1.7.0-openjdk-devel' do
        action :install
end

group 'tomcat' do
  group_name 'tomcat'
  gid '12345'
end


user 'tomcat' do
  comment 'Tomcat User'
  username 'tomcat'
  gid 'tomcat'
  shell '/bin/nologin'
  home '/opt/tomcat'
end

remote_file '/tmp/apache-tomcat-8.5.20.tar.gz' do
  source 'https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.20/bin/apache-tomcat-8.5.20.tar.gz'
  action :nothing
end

http_request 'https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.20/bin/apache-tomcat-8.5.20.tar.gz' do
  message ''
  url 'https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.20/bin/apache-tomcat-8.5.20.tar.gz'
  action :head
  if ::File.exist?('/tmp/apache-tomcat-8.5.20.tar.gz')
    headers 'If-Modified-Since' => File.mtime('/tmp/apache-tomcat-8.5.20.tar.gz').httpdate
  end
  notifies :create, 'remote_file[/tmp/apache-tomcat-8.5.20.tar.gz]', :immediately
end

bash 'extract_module' do
  cwd '/tmp'
  code <<-EOH
    mkdir -p /opt/tomcat
    tar xzf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
    EOH
end

execute "chgrp-tomcat" do
  command "chgrp -R tomcat /opt/tomcat"
  user "root"
  action :run
end

execute "chmod-conf" do
  command "chmod -R g+r /opt/tomcat/conf"
  user "root"
  action :run
end

execute "chmod-conf-gx" do
  command "chmod g+x /opt/tomcat/conf"
  user "root"
  action :run
end

execute "chown-tomcat" do
  cwd '/opt/tomcat'
  command "chown -R tomcat webapps/ work/ temp/ logs/"
  user "root"
  action :run
end

template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
  mode '0755'
end

systemd_unit 'tomcat.service' do
  action :restart
end

service 'tomcat' do
  action [:enable, :start]
end

http_request 'check_tomcat' do
  url 'http://localhost:8080'
end
