class apt::params {

  if $caller_module_name and $caller_module_name != $module_name {
    fail('apt::params is a private class and cannot be accessed directly')
  }

  $root           = '/etc/apt'
  $provider       = '/usr/bin/apt-get'
  $sources_list   = "${root}/sources.list"
  $sources_list_d = "${root}/sources.list.d"
  $conf_d         = "${root}/apt.conf.d"
  $preferences    = "${root}/preferences"
  $preferences_d  = "${root}/preferences.d"

  if $::osfamily != 'Debian' {
    fail('This module only works on Debian or derivatives like Ubuntu')
  }

  $config_files = {
    'conf'   => {
      'path' => $conf_d,
      'ext'  => '',
    },
    'pref'   => {
      'path' => $preferences_d,
      'ext'  => '',
    },
    'list'   => {
      'path' => $sources_list_d,
      'ext'  => '.list',
    }
  }

  $proxy_defaults = {
    'host'  => undef,
    'port'  => 8080,
    'https' => false,
  }

  $file_defaults = {
    'owner' => 'root',
    'group' => 'root',
    'mode'  => '0644',
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
          $ppa_package        = 'python-software-properties'
        }
        'precise': {
          $ppa_options        = '-y'
          $ppa_package        = 'python-software-properties'
        }
        'trusty', 'utopic', 'vivid': {
          $ppa_options        = '-y'
          $ppa_package        = 'software-properties-common'
        }
        default: {
          $ppa_options        = '-y'
          $ppa_package        = 'software-properties-common'
        }
      }
    }
  }
}
