#
# Cookbook Name:: demo
# Recipe:: webserver
#
#

# Install Apache with PHP
include_recipe "openssl"
include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_ssl"

# modify our vhost info
web_app node['demo']['name'] do 
	server_name node['demo']['server_name']
	log_dir node['apache']['log_dir']
	docroot node['demo']['docroot']
end

# Disable default vhost
# note name of default host is OS specific, TODO: make this support other OS
apache_site "default" do
  enable false
end