#
# Cookbook Name:: demo
# Recipe:: packages
#

# Makes sure apt is up to date
include_recipe "apt"
include_recipe "build-essential"
include_recipe "php"