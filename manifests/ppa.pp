# ppa.pp

define apt::ppa() {

  Class['apt'] -> Apt::Ppa[$title]

  exec { "apt-update-${name}":
    command     => "/usr/bin/aptitude update",
    refreshonly => true,
  }

  exec { "add-apt-repository-${name}":
    command => "/usr/bin/add-apt-repository ${name}",
    notify  => Exec["apt-update-${name}"],
  }
}

