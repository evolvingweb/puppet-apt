#Note: This is generally a bad idea. You should not disable keys.
apt::conf { 'unauth':
  priority => 99,
  content  => 'APT::Get::AllowUnauthenticated 1;'
}
