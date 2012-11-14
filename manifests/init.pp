# apt.pp

class apt {
	$root = '/etc/apt'
	$provider = '/usr/bin/apt-get'

  if !defined(Package["python-software-properties"]) {
    package { "python-software-properties":
      ensure => installed,
    }
  }
  
	file { "sources.list":
		name => "${root}/sources.list",
		ensure => present,
		owner => root,
		group => root,
		mode => 644,
	}

	file { "sources.list.d":
		name => "${root}/sources.list.d",
		ensure => directory,
		owner => root,
		group => root,
	}

	exec { "apt_update":
		command => "${provider} update",
		subscribe => [ File["sources.list"], File["sources.list.d"] ],
		refreshonly => true,
	}
}
