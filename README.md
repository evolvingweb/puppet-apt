apt
===

[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-apt.png?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-apt)

Overview
--------

The apt module provides a simple interface for managing APT source, key, and definitions with Puppet.

Module Description
------------------

The apt module automates obtaining and installing software packages on \*nix systems.

***Note:** While this module allows the use of short keys, we **strongly** recommend that you **do not use short keys**, as they pose a serious security issue by opening you up to collision attacks.

Setup
-----

**What apt affects:**

* package/service/configuration files for APT
    * NOTE: Setting the `purge_preferences` or `purge_preferences_d` parameters to 'true' will destroy any existing configuration that was not declared with Puppet. The default for these parameters is 'false'.
* your system's `sources.list` file and `sources.list.d` directory
    * NOTE: Setting the `purge_sources_list` and `purge_sources_list_d` parameters to 'true' will destroy any existing content that was not declared with Puppet. The default for these parameters is 'false'.
* system repositories
* authentication keys

### Beginning with apt

To begin using the apt module with default parameters, declare the class.

    include apt

Puppet code that uses anything from the apt module requires that the core apt class be declared.

Usage
-----

Using the apt module consists predominantly of declaring classes that provide the desired functionality and features.

### apt

`apt` provides a number of common resources and options that are shared by the various defined types in this module, so you **must always** include this class in your manifests.

The parameters for `apt` are not generally required and are predominantly for development environment use cases.

    class { 'apt':
      always_apt_update    => false,
      disable_keys         => undef,
      proxy_host           => false,
      proxy_port           => '8080',
      purge_sources_list   => false,
      purge_sources_list_d => false,
      purge_preferences_d  => false,
      update_timeout       => undef,
      fancy_progress       => undef
    }

Puppet will manage your system's `sources.list` file and `sources.list.d` directory but will do its best to respect existing content.

If you declare your apt class with `purge_sources_list`, `purge_sources_list_d`, `purge_preferences` and `purge_preferences_d` set to 'true', Puppet will unapologetically purge any existing content it finds that wasn't declared with Puppet.

### apt::builddep

Installs the build depends of a specified package.

    apt::builddep { 'glusterfs-server': }

### apt::force

Forces a package to be installed from a specific release. This class is particularly useful when using repositories, like Debian, that are unstable in Ubuntu.

    apt::force { 'glusterfs-server':
      release => 'unstable',
      version => '3.0.3',
      require => Apt::Source['debian_unstable'],
    }

### apt_key

A native Puppet type and provider for managing GPG keys for APT is provided by this module.

    apt_key { 'puppetlabs':
      ensure => 'present',
      id     => '1054B7A24BD6EC30',
    }

You can additionally set the following attributes:

 * `source`: HTTP, HTTPS or FTP location of a GPG key or path to a file on the
             target host;
 * `content`: Instead of pointing to a file, pass the key in as a string;
 * `server`: The GPG key server to use. It defaults to *keyserver.ubuntu.com*;
 * `keyserver_options`: Additional options to pass to `--keyserver`.

Because apt_key is a native type, it can be used in and queried for with MCollective.

### apt::key

Adds a key to the list of keys used by APT to authenticate packages. This type uses the aforementioned `apt_key` native type. As such, it no longer requires
the `wget` command on which the old implementation depended.

    apt::key { 'puppetlabs':
      key        => '1054B7A24BD6EC30',
      key_server => 'pgp.mit.edu',
    }

    apt::key { 'jenkins':
      key        => '9B7D32F2D50582E6',
      key_source => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
    }

### apt::pin

Adds an apt pin for a certain release.

    apt::pin { 'karmic': priority => 700 }
    apt::pin { 'karmic-updates': priority => 700 }
    apt::pin { 'karmic-security': priority => 700 }

Note you can also specifying more complex pins using distribution properties.

    apt::pin { 'stable':
      priority        => -10,
      originator      => 'Debian',
      release_version => '3.0',
      component       => 'main',
      label           => 'Debian'
    }

If you wish to pin a number of packages you may specify the packages as a space
delimited string using the `packages` attribute or pass in an array of package
names.

### apt::hold

When you wish to hold a package in Puppet, it should be done by passing in
'held' as the ensure attribute to the package resource. However, a lot of
public modules do not take this into account and generally do not work well
with an ensure of 'held'.

Moreover, when Puppet is told to hold a package, it holds it at the current version installed; there is no way to tell it to both install a specific version **and** hold that version, unless you use an exec resource that wraps `dpkg --set-selections` or `apt-mark`.

At first glance, it seems this issue could also be solved by passing the version required to the ensure attribute---but that only means that Puppet will install that
version after it processes the package. It does not inform apt that we want
this package to be held; that is, should another package want to upgrade this one (because of a version requirement in a dependency, for example), we want apt to refuse. 

To solve this issue, use apt::hold. Implement this by creating a preferences file with a priority of 1001. Under normal circumstances, this preference will always win. Because the priority is > 1000, apt will maintain the required version, downgrading the current package if necessary. 

With this, you can now set a package's ensure attribute to 'latest' but get the version specified by apt::hold:

    apt::hold { 'vim':
      version => '2:7.3.547-7',
    }

Alternatively, if you want to hold Vim at version 7.3.*, you can pass in a version with a glob:

    apt::hold { 'vim':
      version => '2:7.3.*',
    }

### apt::ppa

Adds a ppa repository using `add-apt-repository`.

    apt::ppa { 'ppa:drizzle-developers/ppa': }

### apt::release

Sets the default apt release. This class is particularly useful when using repositories, like Debian, that are unstable in Ubuntu.

    class { 'apt::release':
      release_id => 'precise',
    }

### apt::source

Adds an apt source to `/etc/apt/sources.list.d/`.

    apt::source { 'debian_unstable':
      comment           => 'This is the iWeb Debian unstable mirror',
      location          => 'http://debian.mirror.iweb.ca/debian/',
      release           => 'unstable',
      repos             => 'main contrib non-free',
      required_packages => 'debian-keyring debian-archive-keyring',
      key               => '8B48AD6246925553',
      key_server        => 'subkeys.pgp.net',
      pin               => '-10',
      include_src       => true,
      include_deb       => true
    }

If you would like to configure your system so the source is the Puppet Labs APT repository:

    apt::source { 'puppetlabs':
      location   => 'http://apt.puppetlabs.com',
      repos      => 'main',
      key        => '1054B7A24BD6EC30',
      key_server => 'pgp.mit.edu',
    }

### apt::update

Runs `apt-get update`, updating the list of available packages and their versions without installing or upgrading any packages. 

The update runs on the first Puppet run after you include the class, then whenever `notify  => Exec['apt_update']` occurs---this should happen when config files get updated or other relevant changes occur. If you set the `always_apt_update` parameter, the update will run on every Puppet run.

### Facts

There are a few facts included in the apt module describing the state of the apt system:

* `apt_updates` --- the number of updates available on the system
* `apt_security_updates` --- the number of updates which are security updates
* `apt_package_updates` --- the package names that are available for update. In Facter 2.0 and later, this will be a list type; in earlier versions, it is a comma-delimited string.

#### Hiera example
<pre>
apt::sources:
  'debian_unstable':
      location: 'http://debian.mirror.iweb.ca/debian/'
      release: 'unstable'
      repos: 'main contrib non-free'
      required_packages: 'debian-keyring debian-archive-keyring'
      key: '9AA38DCD55BE302B'
      key_server: 'subkeys.pgp.net'
      pin: '-10'
      include_src: 'true'
      include_deb: 'true'

  'puppetlabs':
      location: 'http://apt.puppetlabs.com'
      repos: 'main'
      key: '1054B7A24BD6EC30'
      key_server: 'pgp.mit.edu'
</pre>

### Testing

The apt module is mostly a collection of defined resource types, which provide reusable logic that can be leveraged to manage APT. It provides smoke tests for testing functionality on a target system, as well as spec tests for checking a compiled catalog against an expected set of resources.

#### Example Test

This test will set up a Puppet Labs APT repository. Start by creating a new smoke test, called puppetlabs-apt.pp, in the apt module's test folder. In this test, declare a single resource representing the Puppet Labs APT source and GPG key:

    apt::source { 'puppetlabs':
      location   => 'http://apt.puppetlabs.com',
      repos      => 'main',
      key        => '1054B7A24BD6EC30',
      key_server => 'pgp.mit.edu',
    }

This resource creates an APT source named puppetlabs and gives Puppet information about the repository's location and the key used to sign its packages. Puppet leverages Facter to determine the appropriate release, but you can set this directly by adding the release type.

Check your smoke test for syntax errors:

    $ puppet parser validate tests/puppetlabs-apt.pp

If you receive no output from that command, it means nothing is wrong. Then, apply the code:

    $ puppet apply --verbose tests/puppetlabs-apt.pp
    notice: /Stage[main]//Apt::Source[puppetlabs]/File[puppetlabs.list]/ensure: defined content as '{md5}3be1da4923fb910f1102a233b77e982e'
    info: /Stage[main]//Apt::Source[puppetlabs]/File[puppetlabs.list]: Scheduling refresh of Exec[puppetlabs apt update]
    notice: /Stage[main]//Apt::Source[puppetlabs]/Exec[puppetlabs apt update]: Triggered 'refresh' from 1 events>

The above example uses a smoke test to lay out a resource declaration and apply it on your system. In production, you might want to declare your APT sources inside the classes where they’re needed.

Implementation
--------------

### apt::backports

Adds the necessary components to get backports for Ubuntu and Debian. The release name defaults to `$lsbdistcodename`. Setting this manually can cause undefined behavior (read: universe exploding).

By default this class drops a Pin-file for Backports, pinning it to a priority of 200. This is lower than the normal Debian archive, which gets a priority of 500 to ensure that packages with `ensure => latest` don't get magically upgraded from Backports without your explicit permission.

If you raise the priority through the `pin_priority` parameter to *500*, identical to the rest of the Debian mirrors, normal policy goes into effect and the newest version wins/becomes the candidate apt will want to install or upgrade to. This means that if a package is available from Backports it and its dependencies will be pulled in from Backports unless you explicitly set the `ensure` attribute of the `package` resource to `installed`/`present` or a specific version.

Limitations
-----------

This module should work across all versions of Debian/Ubuntu and support all major APT repository management features.

Development
------------

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

License
-------

The original code for this module comes from Evolving Web and was licensed under the MIT license. Code added since the fork of this module is licensed under the Apache 2.0 License like the rest of the Puppet Labs products.

The LICENSE contains both licenses.

Contributors
------------

A lot of great people have contributed to this module. A somewhat current list follows:

* Ben Godfrey <ben.godfrey@wonga.com>
* Branan Purvine-Riley <branan@puppetlabs.com>
* Christian G. Warden <cwarden@xerus.org>
* Dan Bode <bodepd@gmail.com> <dan@puppetlabs.com>
* Daniel Tremblay <github@danieltremblay.ca>
* Garrett Honeycutt <github@garretthoneycutt.com>
* Jeff Wallace <jeff@evolvingweb.ca> <jeff@tjwallace.ca>
* Ken Barber <ken@bob.sh>
* Matthaus Litteken <matthaus@puppetlabs.com> <mlitteken@gmail.com>
* Matthias Pigulla <mp@webfactory.de>
* Monty Taylor <mordred@inaugust.com>
* Peter Drake <pdrake@allplayers.com>
* Reid Vandewiele <marut@cat.pdx.edu>
* Robert Navarro <rnavarro@phiivo.com>
* Ryan Coleman <ryan@puppetlabs.com>
* Scott McLeod <scott.mcleod@theice.com>
* Spencer Krum <spencer@puppetlabs.com>
* William Van Hevelingen <blkperl@cat.pdx.edu> <wvan13@gmail.com>
* Zach Leslie <zach@puppetlabs.com>
* Daniele Sluijters <github@daenney.net>
* Daniel Paulus <daniel@inuits.eu>
