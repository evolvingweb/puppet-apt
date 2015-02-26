define apt::setting (
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

  validate_re($ensure,  ['file', 'present', 'absent'])

  $title_array = split($title, '-')
  $setting_type = $title_array[0]
  $base_name = join(delete_at($title_array, 0), '-')

  validate_re($setting_type, ['\Aconf\z', '\Apref\z', '\Alist\z'], "apt::setting resource name/title must start with either 'conf-', 'pref-' or 'list-'")

  unless is_integer($priority) {
    # need this to allow zero-padded priority.
    validate_re($priority, '^\d+$', 'apt::setting priority must be an integer or a zero-padded integer')
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

  file { "${_path}/${_priority}${base_name}${_ext}":
    ensure  => $ensure,
    owner   => $_file['owner'],
    group   => $_file['group'],
    mode    => $_file['mode'],
    content => $content,
    source  => $source,
  }
}
