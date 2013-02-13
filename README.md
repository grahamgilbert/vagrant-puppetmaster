vagrant-puppetmaster
====================

This is a Vagrantfile for running a testing setup for Puppet. It includes a Puppet Master, Puppet Dashboard and PuppetDB. No idea what Vagrant is?

- Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- Install [Vagrant](http://downloads.vagrantup.com/)
- cd to the cloned directory
- Type in ``vagrant up`` to your terminal window
- Profit

##Why?

I wanted a full Puppet test environment that I could create and destroy easily. Vagrant gives me that.

##The headlines
<table>
<tr><th>IP Address</th><td>192.168.33.10</td></tr>
<tr><th>Dashboard URL</th><td>http://192.168.33.10:3000</td></tr>
<tr><th>Put your manifests in:</th><td>puppet/manifests</td></tr>
<tr><th>Put your modules in:</th><td>puppet/modules</td></tr>
</table>

##A bit more detail on what’s going on
###Puppet

This will set up the latest version of Puppet running as a master using the built in webbrick server. This is fine for testing, but this (amongst other reasons outlined below) makes it unsuitable for use in production.

Place your manifests and modules in ``puppet/manifests`` and ``puppet/modules`` respectively.

The server has the IP address 192.168.33.10 - if your LAN runs on this subnet, make sure you change it in the Vagrantfile.

Other tweaks have been made to the configuration to make it more suitable for testing than the standard configuration:

- Autosigning is enabled for any host
- Any client can revoke a certificate (useful when re-deploying a client for example)

These should be locked down to trusted hosts if using these techniques in production.

###Puppet Dashboard

The Dashboard can be accessed at [http://192.168.33.10:3000](http://192.168.33.10:3000). This also runs using webbrick, which makes it unsuitable for a large scale deployment.

###PuppetDB

PuppetDB is configured and provides the inventory service in the Dashboard.
