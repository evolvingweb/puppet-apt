define apt::conf (
  $content,
  $ensure   = present,
  $priority = '50',
) {
  apt::setting { "conf-${name}":
    ensure       => $ensure,
    base_name    => $name,
    setting_type => 'conf',
    priority     => $priority,
    content      => template('apt/_header.erb', 'apt/conf.erb'),
  }
}
