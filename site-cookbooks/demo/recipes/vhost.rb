#
# Cookbook Name:: demo
# Recipe:: vhost

# Get server name from node (defined in Vagrantfile for our demo)
demo_name = "#{node['demo']['name']}"

# Enable vhost
web_demo demo_name do
  server_name node['demo']['server_name']
  server_aliases node['demo']['server_aliases']
  docroot node['demo']['docroot']
  log_dir node['apache']['log_dir'] 
end

# Disable default vhost config
apache_site "000-default" do
  enable false
end