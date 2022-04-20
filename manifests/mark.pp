# @summary Manages apt-mark settings
#
# @param setting
#   auto, manual, hold, unhold
#   specifies the behavior of apt in case of no more dependencies installed
#   https://manpages.debian.org/stable/apt/apt-mark.8.en.html
#
define apt::mark (
  Enum['auto','manual','hold','unhold'] $setting,
) {
  case $setting {
    'unhold': {
      $unless_cmd = undef
    }
    default: {
      $unless_cmd = "/usr/bin/apt-mark show${setting} ${title} | /bin/fgrep -qs ${title}"
    }
  }
  exec { "/usr/bin/apt-mark ${setting} ${title}":
    onlyif => "/usr/bin/dpkg -l ${title}",
    unless => $unless_cmd,
  }
}
