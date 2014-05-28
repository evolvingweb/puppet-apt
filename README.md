# Apt module for Puppet

## Description
Provides helpful definitions for dealing with Apt.

## Usage

### apt::force
Force a package to be installed from a specific release.  Useful when using repositoires like Debian unstable in Ubuntu.
<pre>
apt::force { "glusterfs-server":
	release => "unstable",
	version => '3.0.3',
	require => Apt::Source["debian_unstable"],
}
</pre>

### apt::pin
Add an apt pin for a certain release.
<pre>
apt::pin { "karmic": priority => 700 }
apt::pin { "karmic-updates": priority => 700 }
apt::pin { "karmic-security": priority => 700 }
</pre>

### apt::ppa
Add a ppa repository using `add-apt-repository`.  Somewhat experimental.
<pre>
apt::ppa { "ppa:drizzle-developers/ppa": }
</pre>

### apt::release
Set the default apt release.  Useful when using repositoires like Debian unstable in Ubuntu.
<pre>
apt::release { "karmic": }
</pre>

### apt::source with keyserver
Add an apt source to `/etc/apt/sources.list.d/`.
<pre>
apt::source { "debian_unstable":
	location => "http://debian.mirror.iweb.ca/debian/",
	release => "unstable",
	repos => "main contrib non-free",
	required_packages => "debian-keyring debian-archive-keyring",
	key => "55BE302B",
	key_server => "subkeys.pgp.net",
	pin => "-10"
}
</pre>

### apt::source without keyserver
Add an apt source to `/etc/apt/sources.list.d/`.
<pre>
apt::source { "zabbix":
	location => " http://repo.zabbix.com/zabbix/2.2/ubuntu",
	release => "precise",
	pin => "-10"
	key_link => "http://repo.zabbix.com/zabbix-official-repo.key",
}
</pre>
