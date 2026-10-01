# == Class: duo_unix::login
#
# Provides duo_unix functionality for SSH via ForceCommand
#
# === Authors
#
# Mark Stanislav <mstanislav@duosecurity.com>
#
class duo_unix::login {
  $ikey              = $duo_unix::ikey
  $skey              = $duo_unix::skey
  $host              = $duo_unix::host
  $group             = $duo_unix::group
  $http_proxy        = $duo_unix::http_proxy
  $fallback_local_ip = $duo_unix::fallback_local_ip
  $failmode          = $duo_unix::failmode
  $pushinfo          = $duo_unix::pushinfo
  $autopush          = $duo_unix::autopush
  $motd              = $duo_unix::motd
  $prompts           = $duo_unix::prompts
  $accept_env_factor = $duo_unix::accept_env_factor
  $usage             = $duo_unix::usage

  file { '/etc/duo/login_duo.conf':
    ensure  => file,
    owner   => 'sshd',
    group   => 'root',
    mode    => '0600',
    content => template('duo_unix/duo.conf.erb'),
    require => Package[$duo_unix::duo_package];
  }

  if $duo_unix::manage_ssh {
    augeas { 'Duo Security SSH Configuration' :
      changes => [
        'set /files/etc/ssh/sshd_config/ForceCommand /usr/sbin/login_duo',
        'set /files/etc/ssh/sshd_config/PermitTunnel no',
        'set /files/etc/ssh/sshd_config/AllowTcpForwarding no',
      ],
      require => Package[$duo_unix::duo_package],
      notify  => Service[$duo_unix::ssh_service];
    }
  }
}
