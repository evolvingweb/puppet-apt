define apt::setting (
  $setting_type,
  $priority   = 50,
  $ensure     = file,
  $source     = undef,
  $content    = undef,
  $file_perms = {},
) {

  $_file = merge($::apt::file_defaults, $file_perms)

  if $content and $source {
    fail('apt::setting cannot have both content and source')
  }

  if !$content and !$source {
    fail('apt::setting needs either of content or source')
  }

  validate_re($setting_type, ['conf', 'pref', 'list'])
  validate_re($ensure,  ['file', 'present', 'absent'])

  unless is_integer($priority) {
    fail('apt::setting priority must be an integer')
  }

  if $source {
    validate_string($source)
  }

  if $content {
    validate_string($content)
  }

  if $setting_type == 'list' {
    $_priority = ''
  } else {
    $_priority = $priority
  }

  $_path = $::apt::config_files[$setting_type]['path']
  $_ext  = $::apt::config_files[$setting_type]['ext']

  file { "${_path}/${_priority}${title}${_ext}":
    ensure  => $ensure,
    owner   => $_file['owner'],
    group   => $_file['group'],
    mode    => $_file['mode'],
    content => $content,
    source  => $source,
  }
}
