# Declare Apt key for apt.puppetlabs.com source
apt::key { 'puppetlabs':
  id      => 'D6811ED3ADEEB8441AF5AA8F4528B6CD9E61EF26',
  server  => 'keyserver.ubuntu.com',
  options => 'http-proxy="http://proxyuser:proxypass@example.org:3128"',
}
