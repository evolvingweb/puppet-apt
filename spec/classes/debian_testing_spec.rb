require 'spec_helper'
describe 'apt::debian::testing', :type => :class do
  it {
    should create_resource("Apt::source", "debian_testing")\
      .with_param("location", "http://debian.mirror.iweb.ca/debian/")\
      .with_param("release", "testing")\
      .with_param("repos", "main contrib non-free")\
      .with_param("required_packages", "debian-keyring debian-archive-keyring")\
      .with_param("key", "55BE302B")\
      .with_param("key_server", "subkeys.pgp.net")\
      .with_param("pin", "-10")
  }
end
