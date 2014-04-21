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
	docroot node['demo']['docroot']
end