# release.pp

define apt::release (

) {

		owner => root,
		group => root,
		mode => 644,
		content => "APT::Default-Release \"${name}\";"
	}
  include apt::params

  file { "${apt::params::root}/apt.conf.d/01release":
}
