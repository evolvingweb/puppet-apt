# force.pp
# force a package from a specific release

define apt::force(
	$release = 'testing',
	$version = false
) {
	
	exec { "aptitude -y -t ${release} install ${name}":
		unless => $version ? {
			false => "dpkg -l | grep ${name}",
			default => "dpkg -l | grep ${name} | grep ${version}"
		}
	}
	
}
