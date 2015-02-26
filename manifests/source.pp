# source.pp
# add an apt source
define apt::source(
  $comment           = $name,
  $ensure            = present,
  $location          = '',
  $release           = $::lsbdistcodename,
  $repos             = 'main',
  $include_src       = false,
  $include_deb       = true,
  $key               = undef,
  $key_server        = 'keyserver.ubuntu.com',
  $key_content       = undef,
  $key_source        = undef,
  $pin               = false,
  $architecture      = undef,
  $trusted_source    = false,
) {
  validate_string($architecture, $comment, $location, $release, $repos, $key_server)
  validate_bool($trusted_source, $include_src, $include_deb)

  if ! $release {
    fail('lsbdistcodename fact not available: release parameter required')
  }

  apt::setting { "list-${name}":
    ensure  => $ensure,
    content => template('apt/_header.erb', 'apt/source.list.erb'),
    notify  => Exec['apt_update'],
  }

  if ($pin != false) {
    # Get the host portion out of the url so we can pin to origin
    $url_split = split($location, '/')
    $host      = $url_split[2]

    apt::pin { $name:
      ensure   => $ensure,
      priority => $pin,
      before   => Apt::Setting["list-${name}"],
      origin   => $host,
    }
  }

  # We do not want to remove keys when the source is absent.
  if $key and ($ensure == 'present') {
    apt::key { "Add key: ${key} from Apt::Source ${title}":
      ensure      => present,
      key         => $key,
      key_server  => $key_server,
      key_content => $key_content,
      key_source  => $key_source,
      before      => Apt::Setting["list-${name}"],
    }
  }

  # Need anchor to provide containment for dependencies.
  anchor { "apt::source::${name}":
    require => Class['apt::update'],
  }
}
