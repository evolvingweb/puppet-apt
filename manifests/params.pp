class apt::params {
  $root           = '/etc/apt'
  $provider       = '/usr/bin/apt-get'
  $sources_list_d = "${root}/sources.list.d"
  $apt_conf_d     = "${root}/apt.conf.d"
  $preferences_d  = "${root}/preferences.d"

  if $::osfamily != 'Debian' {
    fail('This module only works on Debian or derivatives like Ubuntu')
  }

  case $::lsbdistid {
    'ubuntu', 'debian': {
      $distid = $::lsbdistid
      $distcodename = $::lsbdistcodename
    }
    'linuxmint': {
      if $::lsbdistcodename == 'debian' {
        $distid = 'debian'
        $distcodename = 'wheezy'
      } else {
        $distid = 'ubuntu'
        $distcodename = $::lsbdistcodename ? {
          'qiana'  => 'trusty',
          'petra'  => 'saucy',
          'olivia' => 'raring',
          'nadia'  => 'quantal',
          'maya'   => 'precise',
        }
      }
    }
    '': {
      fail('Unable to determine lsbdistid, is lsb-release installed?')
    }
    default: {
      fail("Unsupported lsbdistid (${::lsbdistid})")
    }
  }
  case $distid {
    'ubuntu': {
      case $distcodename {
        'lucid': {
          $ppa_options        = undef
        }
        'precise', 'trusty', 'utopic', 'vivid': {
          $ppa_options        = '-y'
        }
        default: {
          $ppa_options        = '-y'
        }
      }
    }
  }
}
