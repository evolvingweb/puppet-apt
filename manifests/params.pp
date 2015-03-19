class apt::params {

  if $::osfamily != 'Debian' {
    fail('This module only works on Debian or derivatives like Ubuntu')
  }

  # Strict variables facts lookup compatibility
  $xfacts = {
    'lsbdistcodename' => defined('$lsbdistcodename') ? {
      true    => $::lsbdistcodename,
      default => undef,
    },
    'lsbdistrelease' => defined('$lsbdistrelease') ? {
      true    => $::lsbdistrelease,
      default => undef,
    },
    'lsbmajdistrelease' => defined('$lsbmajdistrelease') ? {
      true    => $::lsbmajdistrelease,
      default => undef,
    },
    'lsbdistdescription' => defined('$lsbdistdescription') ? {
      true    => $::lsbdistdescription,
      default => undef,
    },
    'lsbminordistrelease' => defined('$lsbminordistrelease') ? {
      true    => $::lsbminordistrelease,
      default => undef,
    },
    'lsbdistid' => defined('$lsbdistid') ? {
      true    => $::lsbdistid,
      default => undef,
    },
  }

  $root           = '/etc/apt'
  $provider       = '/usr/bin/apt-get'
  $sources_list   = "${root}/sources.list"
  $sources_list_d = "${root}/sources.list.d"
  $conf_d         = "${root}/apt.conf.d"
  $preferences    = "${root}/preferences"
  $preferences_d  = "${root}/preferences.d"
  $keyserver      = 'keyserver.ubuntu.com'

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

  $update_defaults = {
    'frequency' => 'reluctantly',
    'timeout'   => undef,
    'tries'     => undef,
  }

  $proxy_defaults = {
    'host'  => undef,
    'port'  => 8080,
    'https' => false,
  }

  $purge_defaults = {
    'sources.list'   => true,
    'sources.list.d' => true,
    'preferences'    => true,
    'preferences.d'  => true,
  }

  $source_key_defaults = {
    'server'  => $keyserver,
    'options' => undef,
    'content' => undef,
    'source'  => undef,
  }

  $include_defaults = {
    'deb' => true,
    'src' => false,
  }

  case $xfacts['lsbdistid'] {
    'ubuntu', 'debian': {
      $distid = $xfacts['lsbdistid']
      $distcodename = $xfacts['lsbdistcodename']
    }
    'linuxmint': {
      if $xfacts['lsbdistcodename'] == 'debian' {
        $distid = 'debian'
        $distcodename = 'wheezy'
      } else {
        $distid = 'ubuntu'
        $distcodename = $xfacts['lsbdistcodename'] ? {
          'qiana'  => 'trusty',
          'petra'  => 'saucy',
          'olivia' => 'raring',
          'nadia'  => 'quantal',
          'maya'   => 'precise',
        }
      }
    }
    undef: {
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
    '', default: {
      $ppa_options = undef
      $ppa_package = undef
    }
  }
}
