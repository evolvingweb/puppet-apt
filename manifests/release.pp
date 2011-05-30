# release.pp

class apt::release (
  $release_id
) {

		owner => root,
		group => root,
		mode => 644,
	}
  include apt::params

  file { "${apt::params::root}/apt.conf.d/01release":
    content => "APT::Default-Release \"${release_id}\";"
}
