#
# Cookbook Name:: demo
# Recipe:: db
#

# Install MySQL server & MySQL client
node.set['mysql']['server_root_password'] = 'your_password'
node.set['mysql']['server_debian_password'] = 'your_password'
node.set['mysql']['server_repl_password'] = 'your_password'
node.set['mysql']['port'] = '3308'
node.set['mysql']['data_dir'] = '/data'


include_recipe "mysql::server"
include_recipe "mysql::client"

include_recipe "php::module_mysql" # better location?

#TODO: much more legit configuration; secure MySQL;