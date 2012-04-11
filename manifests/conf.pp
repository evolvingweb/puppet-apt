define apt::conf (
  $priority = '50',
  $content
  ) {

  include apt::params

  $root       = "${apt::params::root}"
  $apt_conf_d = "${apt::params::apt_conf_d}"

  file { "${apt_conf_d}/${priority}${name}":
    content => $content,
    owner   => root,
    group   => root,
    mode    => 0644,
  }
}
