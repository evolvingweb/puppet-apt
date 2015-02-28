#
class apt(
  $update               = {},
  $purge                = {},
  $proxy                = {},
  $sources              = undef,
) inherits ::apt::params {


  $frequency_options = ['always','daily','weekly','reluctantly']
  validate_hash($update)
  if $update['frequency'] {
    validate_re($update['frequency'], $frequency_options)
  }
  if $update['always'] {
    validate_bool($update['always'])
  }
  if $update['timeout'] {
    unless is_integer($update['timeout']) {
      fail('timeout value for update must be an integer')
    }
  }
  if $update['tries'] {
    unless is_integer($update['tries']) {
      fail('tries value for update must be an integer')
    }
  }

  $_update = merge($::apt::update_defaults, $update)
  include apt::update

  validate_hash($purge)
  if $purge['sources.list'] {
    validate_bool($purge['sources.list'])
  }
  if $purge['sources.list.d'] {
    validate_bool($purge['sources.list.d'])
  }
  if $purge['preferences'] {
    validate_bool($purge['preferences'])
  }
  if $purge['preferences.d'] {
    validate_bool($purge['preferences.d'])
  }

  $_purge = merge($::apt::purge_defaults, $purge)

  validate_hash($proxy)
  if $proxy['host'] {
    validate_string($proxy['host'])
  }
  if $proxy['port'] {
    unless is_integer($proxy['port']) {
      fail('$proxy port must be an integer')
    }
  }
  if $proxy['https'] {
    validate_bool($proxy['https'])
  }

  $_proxy = merge($apt::proxy_defaults, $proxy)

  if $proxy['host'] {
    apt::setting { 'conf-proxy':
      priority => '01',
      content  => template('apt/_header.erb', 'apt/proxy.erb'),
    }
  }

  $sources_list_content = $_purge['sources.list'] ? {
    false => undef,
    true  => "# Repos managed by puppet.\n",
  }

  $preferences_ensure = $_purge['preferences'] ? {
    false => file,
    true  => absent,
  }

  if $_update['always'] {
    Exec <| title=='apt_update' |> {
      refreshonly => false,
    }
  }

  apt::setting { 'conf-update-stamp':
    priority => 15,
    content  => template('apt/_header.erb', 'apt/15update-stamp.erb'),
  }

  file { 'sources.list':
    ensure  => file,
    path    => $::apt::sources_list,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => $sources_list_content,
    notify  => Exec['apt_update'],
  }

  file { 'sources.list.d':
    ensure  => directory,
    path    => $::apt::sources_list_d,
    owner   => root,
    group   => root,
    mode    => '0644',
    purge   => $_purge['sources.list.d'],
    recurse => $_purge['sources.list.d'],
    notify  => Exec['apt_update'],
  }

  file { 'preferences':
    ensure => $preferences_ensure,
    path   => $::apt::preferences,
    owner  => root,
    group  => root,
    mode   => '0644',
    notify => Exec['apt_update'],
  }

  file { 'preferences.d':
    ensure  => directory,
    path    => $::apt::preferences_d,
    owner   => root,
    group   => root,
    mode    => '0644',
    purge   => $_purge['preferences.d'],
    recurse => $_purge['preferences.d'],
    notify  => Exec['apt_update'],
  }

  # Need anchor to provide containment for dependencies.
  anchor { 'apt::update':
    require => Class['apt::update'],
  }

  # manage sources if present
  if $sources != undef {
    validate_hash($sources)
    create_resources('apt::source', $sources)
  }
}
