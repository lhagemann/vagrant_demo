# Vagrant for webdevelopers

A talk I gave to the NH PHP meetup about using [Vagrant](http://vagrantup.com) for development environment management. 

This is an introductory level talk about using Vagrant with examples of bash scripting and Chef automation for deployment. The scripts are not intendend to be production ready, but are simply examples relevant to the walkthrough to expose the elements of Vagrant for web developers. Keeping in mind this was a 60 minute talk, so the provisioning scripts and recipes are very basic.

## Why should Web Developers use Vagrant?
* Benefits of Consistent, Repeatable Development Environment
* Shared folders with host for easy editing in your favorite editor
* Vagrant for Clustering to replicate production environment locally
* Configuration Automation
* Learning DB or Server Administration
* Vagrant Share via Vagrant Cloud (March 2014)

## Installing Vagrant and Virtual Box
Virtual Box or VMware or AWS "providers" of virtualization environments. Virtual Box is the built in provider for Vagrant, with Vagrant and Virtual Box installed we can begin.

[Install virtual box](https://www.virtualbox.org/wiki/Downloads) using the OS specific installation process

[Install vagrant](http://docs.vagrantup.com/v2/installation/index.html) using your OS package installer and provided packages 

With these installed we run `vagrant init` at the command line and we're given a Vagrantfile which is what we use for our configuration (more about that later). The first thing we do is tell vagrant what kind of virtual machine we want to work with.

## Vagrant Boxes
Vagrant works with "base boxes", VMs with the OS already installed. Some include other packages/services pre-installed. When working with a team, a pre-built base box makes getting up and running even faster. 

Virtual Machine (VM) is virtual hardware: Disk space, RAM, etc.

VM images have many advantages for developers. They are easily cloned, shared, and available on line.

Specifying your the box (virtual machine image) to use for your project is always the first step when initializing a vagrant environment. (technically second, we'll get to that)

When working with VMs your local machine is the `host` and the VM is the `guest`. These distinctions will be important during configuration.

*Adding boxes*

	vagrant box add {name} {url}

Using [vagrantbox.es][boxes] copy box name / url to paste into Vagrant file

You can see what boxes you have available at any time with the following command

	vagrant box list

You initialize a vagrant instance for an already added box with 
	
	vagrant init {name}

First vagrant up:

	vagrant init hashicorp/precise32

using the default init with the passed in box reference to a version of Ubuntu which is a box built for quickly getting up and running with vagrant. It will retrieve the box from the [Vagrant cloud][cloud]

## The Vagrantfile

This is the primary element for configuring your Vagrant environment. The default Vagrant file generated includes extensive documentation about the different configuration elements available. 

By initializing with a box name (and optional url) on the command line, we'll find the configuration already populated. 

	VAGRANTFILE_API_VERSION = "2"

	Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	  # All Vagrant configuration is done here. The most common configuration
	  # options are documented and commented below. For a complete reference,
	  # please see the online documentation at vagrantup.com.

	  # Every Vagrant virtual environment requires a box to build off of.
	  config.vm.box = "hashicorp/precise32"

	  # The url from where the 'config.vm.box' box will be fetched if it
	  # doesn't already exist on the user's system.
	  # config.vm.box_url = "http://domain.com/path/to/above.box"
	  ...

Because we are using a box from the [Vagrant Cloud][cloud] there is no need to specify a url. In the event of using a box either locally, or on a shared server, you would uncomment and populate the `config.vm.box_url` setting.

Other settings which are controlled by the Vagrantfile include:

* port forwarding
	* allow the host (your machine) to access services on the guest (vagrant box)
* shared local folders
* networking
* provisioning method

By default Vagrant gives us one shared folder, which is our project folder shared at `/vagrant` on the guest. Additional shared folders can be defined in the config settings. 

## Vagrant Management
Vagrant is managed through the command line and there are only a handful of commands to use:
* `vagrant init`: Initialize a vagrant environment
* `vagrant up` : Bring up your Vagrant instance, based on the configuration within your Vagrantfile
* `vagrant status` : What is the status (up, down, not created) of your vagrant VM
* `vagrant ssh` : SSH into your VM for command access to the guest
* `vagrant reload` : reload your Vagrantfile if you've made changes to the Vagrant configuration
* `vagrant provision` : run (or re-run) the provisioning 
* `vagrant halt` : Shutdown your VM (but keep the instance on disk)
* `vagrant destroy` : Completely erase the VM instance from your host


## Vagrant Provisioning
### Shell (bash)

At this point we could manually build our server right here on the command line of the guest (`vagrant ssh`). But provisioning is what Vagrant is for. 

We'll start with a simple shell script to install our LAMP stack (see `bootstrap.sh`).

Add these lines to our Vagrant file:

	# provision with shell
	config.vm.provision :shell, :path => "bootstrap.sh"

The `path` attribute is relative to your Vagrantfile.

To demonstrate that the webserver is running after this provisioning, we first access our guest with

	vagrant ssh

the we use

	wget -qO- 127.0.0.1

to return the index page of our server. 

Note in the `bootstrap.sh` that we have symlinked the default document root location to our shared folder `/vagrant`. The index file for our server is the `index.html` in our project. 

Shared Folders --- local folders linked to the guest. You can edit locally and have the files served by the guest VM. Makes editing your PHP scripts etc easy on your local workstation with your preferred editor. 

Edit the index.html file and use the `wget` command to see this. 

Of course, we really want to be able to see our work in a true browser, running on our local machine. We use the `forwarded_port` setting for this

	# Create a forwarded port mapping which allows access to a specific port
	# within the machine from a port on the host machine. In the example below,
	# accessing "localhost:8080" will access port 80 on the guest machine.
	config.vm.network "forwarded_port", guest: 80, host: 8080

After editing the Vagrantfile to set the forward ports, reload with `vagrant reload`

Now, we can vist `http://localhost:8080` on our local machine to see the index page in our browser.

### Vagrant Provisioning with Chef
You can use Chef Solo to provision vagrant boxes, which runs stand alone, requires no connection to a Chef server, appropriate for development purposes, but if you're going to use Chef to provision production servers there are other options which are more suitable (but are out of scope for this talk)

#### Chef Provisioning Requirements
* [Berkshelf](http://berkshelf.com)
	* `gem install berkshelf`
* [vagrant-berkshelf](https://github.com/riotgames/vagrant-berkshelf)
	* `vagrant plugin install vagrant-berkshelf`
* [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus)
	* `vagrant plugin install vagrant-omnibus`

For our purposes, we'll use shared cookbooks from the Chef Community. Shared cookbooks, either with the community or within an organization are most easily managed through [Berkshelf](http://berkshelf.com/). Vagrant uses plugins to work with 3rd party tools (those that are supported)

use `vagrant plugin list` to verify you have the plugins for berkshelf and omnibus installed.

We want to start from scratch for this provisioning (since our shell script did some installations for us) so destroy your current VM with `vagrant destroy`.

Edit our Vagrant file to provision with Chef. First remove the setting to provision with Shell and add the following lines to support using Berkshelf and Chef:

	# use berkshelf to manage our cookbooks
	# tell vagrant we want to use chef to provision
	config.berkshelf.enabled = true
  	config.omnibus.chef_version = :latest

Find the chef provisioning block in the Vagrantfile which is commented out, and replace with the following:

	config.vm.provision "chef_solo" do |chef|
    	chef.add_recipe "demo::packages"
    	chef.add_recipe "demo::webserver"
    	chef.add_recipe "demo::db"

	    chef.json = { 
	      :demo => {
	        :name => 'nhphp',
	        :docroot => '/vagrant',
	        :server_name => 'nhphp'
	      }
	    }
	end

This will use the cookbooks supplied in this demo to provision a LAMP server, again with our document set to be our project folder shared at `/vagrant`

# Conclusion
I hope this has been enough to whet your appetite for how easily Vagrant can be used to create a development environment. The files included in this demostration should get you started on your way.

Included in the demo files are `Vagrantfile_bash` and `Vagrantfile_chef` which are reference files for each of the provisioning methods. (Renaming either to `Vagrantfile` will provision vagrant on `vagrant up` with its respective setting.)


[v]: <http://www.vagrantup.com/> "Vagrant Home Page"
[vb]: <https://www.virtualbox.org/> "Virtual Box Home Page"
[boxes]: <http://www.vagrantbox.es/> "Vagrant Base Boxes"
[cloud]: <https://vagrantcloud.com/> "Vagrant Cloud"
