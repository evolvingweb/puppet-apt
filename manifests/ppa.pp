# ppa.pp

define apt::ppa(
	
) {
	include apt
	
	exec { "/usr/bin/add-apt-repository ${name}":
		require => Package["python-software-properties"],
		# TODO: unless => 'check'
	}
}

