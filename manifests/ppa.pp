# ppa.pp

define apt::ppa(
	
) {
	include apt
	
	exec { "add-apt-repository ${name}":
		require => Package["python-software-properties"],
		# TODO: unless => 'check'
	}
}

