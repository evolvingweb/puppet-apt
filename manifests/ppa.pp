# ppa.pp

define apt::ppa(

) {
	include apt

    package { "python-software-properties": }

    exec { "apt-update":
        command     => "/usr/bin/apt-get update",
        refreshonly => true,
    }

    exec { "/usr/bin/add-apt-repository ${name}":
        require => Package["python-software-properties"],
        notify => Exec["apt-update"]
    }
}

