define apt::conf (
  $content,
  $ensure   = present,
  $priority = '50'
) {

  file { "${apt::conf_d}/${priority}${name}":
    ensure  => $ensure,
    content => template('apt/_header.erb', 'apt/conf.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
  }
}
