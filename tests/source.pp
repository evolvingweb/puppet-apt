class { 'apt': }
apt::source { 'foo':
  location => '',
  release => 'karmic',
  repos => 'main',
  include_src => true,
  required_packages => false,
  key => false,
  key_server => 'keyserver.ubuntu.com',
  pin => '600'
}
