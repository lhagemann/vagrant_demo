# NH PHP Vagrant for webdevelopers

A talk I gave to the NH PHP meetup about using [Vagrant](http://vagrantup.com) for development environment management. 

This is simply files I used during the talk, they may be of use for reference to others. Keeping in mind this was a 60 minute talk, so the provisioning scripts and recipes are very basic.


## Chef Provisioning Requirements
* [Berkshelf](http://berkshelf.com)
	* `gem install berkshelf`
* [vagrant-berkshelf](https://github.com/riotgames/vagrant-berkshelf)
	* `vagrant plugin install vagrant-berkshelf`
* [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus)
	* `vagrant plugin install vagrant-omnibus`

