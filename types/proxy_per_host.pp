# @summary Adds per-host overrides to the system default APT proxy configuration
#
# @param scope
#   Specifies the scope of the override.  Valid options: a string containing a hostname.
#
# @param host
#   Specifies a proxy host to be stored in `/etc/apt/apt.conf.d/01proxy`. Valid options: a string containing a hostname.
#
# @param port
#   Specifies a proxy port to be stored in `/etc/apt/apt.conf.d/01proxy`. Valid options: an integer containing a port number.
#
# @param https
#   Specifies whether to enable https for this override.
#
# @param direct
#   Specifies whether or not to use a `DIRECT` target to bypass the system default proxy.
#
type Apt::Proxy_Per_Host = Struct[
  {
    scope      => String,
    host       => Optional[String],
    port       => Optional[Integer[1, 65535]],
    https      => Optional[Boolean],
    direct     => Optional[Boolean],
  }
]
