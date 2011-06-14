class { 'apt': }
class { 'apt::release':
  release_id => 'foo'
}
