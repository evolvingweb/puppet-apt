type Apt::Proxy = Struct[
  {
    ensure => Optional[Enum['file', 'present', 'absent']],
    host   => Optional[String],
    port   => Optional[Integer[0, 65535]],
    https  => Optional[Boolean],
    direct => Optional[Boolean],
  }
]
