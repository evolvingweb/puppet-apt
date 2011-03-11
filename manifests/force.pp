# force.pp
# force a package from a specific release

define apt::force(
	$release = 'testing',
	$version = false
) {

	exec { "/usr/bin/aptitude -y -t ${release} install ${name}":
		unless => $version ? {
			false => "/usr/bin/dpkg -l | grep ${name}",
			default => "/usr/bin/dpkg -l | grep ${name} | grep ${version}"
		}
	}

}
