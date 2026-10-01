# == Class: duo_unix::pam
#
# Provides duo_unix functionality for SSH via PAM
#
# === Authors
#
# Mark Stanislav <mstanislav@duosecurity.com>
#

class duo_unix::pam {
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

  $aug_pam_path = "/files${duo_unix::pam_file}"
  $aug_match    = "${aug_pam_path}/*/module[. = '${duo_unix::pam_module}']"

  file { '/etc/duo/pam_duo.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('duo_unix/duo.conf.erb'),
    require => Package[$duo_unix::duo_package];
  }

  if $duo_unix::manage_ssh {
    augeas { 'Duo Security SSH Configuration' :
      changes => [
        'set /files/etc/ssh/sshd_config/UsePAM yes',
        'set /files/etc/ssh/sshd_config/UseDNS no',
        'set /files/etc/ssh/sshd_config/ChallengeResponseAuthentication yes',
      ],
      require => Package[$duo_unix::duo_package],
      notify  => Service[$duo_unix::ssh_service];
    }
  }

  if $duo_unix::manage_pam {
    if $facts['os']['family'] == 'RedHat' {
      augeas { 'PAM Configuration':
        changes => [
          "set ${aug_pam_path}/2/control ${duo_unix::pam_unix_control}",
          "ins 100 after ${aug_pam_path}/2",
          "set ${aug_pam_path}/100/type auth",
          "set ${aug_pam_path}/100/control sufficient",
          "set ${aug_pam_path}/100/module ${duo_unix::pam_module}",
        ],
        require => Package[$duo_unix::duo_package],
        onlyif  => "match ${aug_match} size == 0";
      }
    } else {
      augeas { 'PAM Configuration':
        changes => [
          "set ${aug_pam_path}/1/control ${duo_unix::pam_unix_control}",
          "ins 100 after ${aug_pam_path}/1",
          "set ${aug_pam_path}/100/type auth",
          "set ${aug_pam_path}/100/control '[success=1 default=ignore]'",
          "set ${aug_pam_path}/100/module ${duo_unix::pam_module}",
        ],
        require => Package[$duo_unix::duo_package],
        onlyif  => "match ${aug_match} size == 0";
      }
    }
  }
}
