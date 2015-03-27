$location = $::apt::distcodename ? {
  'squeeze' => 'http://backports.debian.org/debian-backports',
  'wheezy'  => 'http://ftp.debian.org/debian/',
  default   => 'http://archive.ubuntu.com/ubuntu',
}

if $::apt::distid == 'debian' {
  $repos   = 'main contrib non-free'
  $key     = 'A1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553'
  $release = $::apt::distcodename
} else {
  $repos   = 'main universe multiverse restricted'
  $key     = '630239CC130E1A7FD81A27B140976EAF437D05B5'
  $release = $::apt::distcodename
}

# set up the actual backports
apt::pin { 'backports':
  release  => "${release}-backports",
  priority => 200,
}

apt::source { 'backports':
  location => $location,
  release  => "${release}-backports",
  repos    => $repos,
  key      => {
    id     => $key,
    server => 'pgp.mit.edu',
  },
}
