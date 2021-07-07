# Set up a backport for Linux Mint qiana
class { 'apt': }
class { 'apt::backports':
  location => 'http://us.archive.ubuntu.com/ubuntu',
  release  => 'trusty-backports',
  repos    => 'main universe multiverse restricted',
  key      => {
    id     => '630239CC130E1A7FD81A27B140976EAF437D05B5',
    server => 'keyserver.ubuntu.com',
  },
}
