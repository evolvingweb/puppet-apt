# source.pp
# add an apt source
define apt::source(
  $comment        = $name,
  $ensure         = present,
  $location       = '',
  $release        = $::apt::xfacts['lsbdistcodename'],
  $repos          = 'main',
  $include_src    = false,
  $include_deb    = true,
  $key            = undef,
  $pin            = false,
  $architecture   = undef,
  $trusted_source = false,
) {
  validate_string($architecture, $comment, $location, $repos)
  validate_bool($trusted_source, $include_src, $include_deb)

  unless $release {
    fail('lsbdistcodename fact not available: release parameter required')
  }

  $_before = Apt::Setting["list-${title}"]

  if $key {
    if is_hash($key) {
      unless $key['id'] {
        fail('key hash must contain at least an id entry')
      }
      $_key = merge($::apt::source_key_defaults, $key)
    } else {
      validate_string($key)
      $_key = $key
    }
  }

  apt::setting { "list-${name}":
    ensure  => $ensure,
    content => template('apt/_header.erb', 'apt/source.list.erb'),
  }

  if ($pin != false) {
    # Get the host portion out of the url so we can pin to origin
    $url_split = split($location, '/')
    $host      = $url_split[2]

    apt::pin { $name:
      ensure   => $ensure,
      priority => $pin,
      before   => $_before,
      origin   => $host,
    }
  }

  # We do not want to remove keys when the source is absent.
  if $key and ($ensure == 'present') {
    if is_hash($_key) {
      apt::key { "Add key: ${_key['id']} from Apt::Source ${title}":
        ensure  => present,
        id      => $_key['id'],
        server  => $_key['server'],
        content => $_key['content'],
        source  => $_key['source'],
        options => $_key['options'],
        before  => $_before,
      }
    } else {
      apt::key { "Add key: ${_key} from Apt::Source ${title}":
        ensure => present,
        id     => $_key,
        before => $_before,
      }
    }
  }
}
