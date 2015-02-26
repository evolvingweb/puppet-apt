define apt::conf (
  $content,
  $ensure   = present,
  $priority = '50',
) {
  apt::setting { "conf-${name}":
    ensure   => $ensure,
    priority => $priority,
    content  => template('apt/_header.erb', 'apt/conf.erb'),
  }
}
