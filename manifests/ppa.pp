# ppa.pp

define apt::ppa(

) {
	include apt

    package { "python-software-properties": }

	exec { "/usr/bin/add-apt-repository ${name}":
		require => Package["python-software-properties"],
		# TODO: unless => 'check'
	}
}

