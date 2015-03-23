# If your environment includes mint you'll need something more like this:
#
#$location = $::lsbdistcodename ? {
#  'squeeze' => 'http://backports.debian.org/debian-backports',
#  'wheezy'  => 'http://ftp.debian.org/debian/',
#  'debian'  => 'http://ftp.debian.org/debian/', #thanks LinuxMint
#  default   => 'http://us.archive.ubuntu.com/ubuntu',
#}
#
#if ($::lsbdistid == 'LinuxMint' and $::lsbdistcodename == 'debian') or $::lsbdistid == 'Debian' {
#  $repos = 'main contrib non-free'
#  $key   = 'A1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553'
#  if $::lsbdistid == 'LinuxMint' {
#    $release = 'wheezy'
#  } else {
#    $release = downcase($::lsbdistrelease)
#  }
#} else {
#  if $::lsbdistid == 'LinuxMint' {
#    $release = $::lsbdistcodename ? {
#      'qiana'  => 'trusty',
#      'petra'  => 'saucy',
#      'olivia' => 'raring',
#      'nadia'  => 'quantal',
#      'maya'   => 'precise',
#    }
#  } else {
#    $release = downcase($::lsbdistrelease)
#  }
#  $repos = 'main universe multiverse restricted'
#  $key   = '630239CC130E1A7FD81A27B140976EAF437D05B5'
#}

## Start logic to figure out backports location, repos, key, and release
if $::lsbdistid == 'Debian' {
  $repos    = 'main contrib non-free'
  $key      = 'A1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553'
  $release  = downcase($::lsbdistrelease)
  $location = $::lsbdistcodename ? {
    'squeeze' => 'http://backports.debian.org/debian-backports',
    'wheezy'  => 'http://ftp.debian.org/debian/',
    default   => 'http://http.debian.net/debian/',
  }
} else {
  $release  = downcase($::lsbdistrelease)
  $repos    = 'main universe multiverse restricted'
  $key      = '630239CC130E1A7FD81A27B140976EAF437D05B5'
  $location = 'http://us.archive.ubuntu.com/ubuntu',
}
## end logic for variables


# set up the actual backports
apt::pin { 'backports':
  before   => Apt::Source['backports'],
  release  => "${release}-backports",
  priority => 200,
}

apt::source { 'backports':
  location => $location,
  release  => "${release}-backports",
  repos    => $repos,
  key      => {
    id       => $key,
    server   => 'pgp.mit.edu',
  },
}
