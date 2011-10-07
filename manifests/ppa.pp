# ppa.pp

define apt::ppa(

) {
    require apt

    exec { "apt-update-${name}":
        command     => "/usr/bin/aptitude update",
        refreshonly => true,
    }

    exec { "add-apt-repository-${name}":
        command => "/usr/bin/add-apt-repository ${name}",
        notify  => Exec["apt-update-${name}"],
    }

    /* That's the way /usr/lib/python2.6/dist-packages/softwareproperties/ppa.py does it... */
    $typename = split($name, ':')

    if ($typename[0] == 'ppa') {
	$ppaownername = split($typename[1], '/')
	$ppaowner = $ppaownername[0]

	if $ppaownername[1] =~ /.+/ {
		$ppaname = $ppaownername[1]
	} else {
		$ppaname = "ppa"
	}

	$file = "$ppaowner-$ppaname-$lsbdistcodename"

	Exec["add-apt-repository-${name}"] { creates +> "/etc/apt/sources.list.d/$file.list" }
    }
}
