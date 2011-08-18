# ppa.pp

define apt::ppa() {

  Class['apt'] -> Apt::Ppa[$title]

  Exec {
    onlyif => "/usr/bin/test ! $(/bin/ls /etc/apt/sources.list.d | /bin/grep -v $(echo \"${title}\" | /usr/bin/gawk 'match(\$0, /^ppa:(.*)\/(.*)$/, vals) {printf \"%s-%s\", vals[1], vals[2]}'))",
  }

  exec { "apt-update-${name}":
    command     => "/usr/bin/aptitude update",
    refreshonly => true,
  }

  exec { "add-apt-repository-${name}":
    command => "/usr/bin/add-apt-repository ${name}",
    notify  => Exec["apt-update-${name}"],
  }
}

