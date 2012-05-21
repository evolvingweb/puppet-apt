# pin.pp
# pin a release in apt, useful for unstable repositories

define apt::pin(
  $ensure   = present,
  $packages = '*',
  $priority = 0,
  $release  = '',
  $origin   = ''
) {

  include apt::params

  $preferences_d = $apt::params::preferences_d

  if $release != '' {
    $pin = "release a=${release}"
  } elsif $origin != '' {
    $pin = "origin \"${origin}\""
  } else {
    err("Apt::Pin needs either $release or $origin")
  }

  file { "${name}.pref":
    ensure  => $ensure,
    path    => "${preferences_d}/${name}",
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("apt/pin.pref.erb"),
  }
}
