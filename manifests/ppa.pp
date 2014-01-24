# ppa.pp

define apt::ppa(

) {
    require apt

    $ppa  = regsubst($name, '^(ppa:)(.*)$', '\2')
    $ppa_apt_name = regsubst($ppa, '/', '-', 'G')
    $ppa_list_file = "${ppa_apt_name}-${::lsbdistcodename}.list"

    exec { "apt-update-${name}":
        command     => '/usr/bin/aptitude update',
        refreshonly => true,
    }

    exec { "add-apt-repository-${name}":
        command => "/usr/bin/add-apt-repository ${name}",
        creates => "/etc/apt/sources.list.d/${ppa_list_file}",
        notify  => Exec["apt-update-${name}"];
    }
}

