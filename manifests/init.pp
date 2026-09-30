# == Class: duo_unix
#
# Core class for duo_unix module
#
# === Authors
#
# Mark Stanislav <mstanislav@duosecurity.com>
#
class duo_unix (
  String $package_version,
  String $repo_uri,
  $usage = undef,
  $ikey = undef,
  $skey = undef,
  $host = undef,
  $group = undef,
  $http_proxy = undef,
  $fallback_local_ip = 'no',
  $failmode = 'safe',
  $pushinfo = 'no',
  $autopush = 'no',
  $motd = 'no',
  $prompts = '3',
  $accept_env_factor = 'no',
  $manage_ssh = true,
  $manage_pam = true,
  $pam_unix_control = 'requisite',
) {
  if $ikey == '' or $skey == '' or $host == '' {
    fail('ikey, skey, and host must all be defined.')
  }

  if $usage != 'login' and $usage != 'pam' {
    fail('You must configure a usage of duo_unix, either login or pam.')
  }

  case $facts['os']['name'] {
    'RedHat', 'CentOS', 'OracleLinux', 'Amazon', 'Rocky': {
      $duo_package = 'duo_unix'
      $ssh_service = 'sshd'
      $gpg_file    = '/etc/pki/rpm-gpg/RPM-GPG-KEY-DUO'

      $pam_file = $facts['os']['release']['major'] ? {
        '5'              => '/etc/pam.d/system-auth',
        /(2|6|7|8|9|2014)/ => '/etc/pam.d/password-auth',
        default          => '/etc/pam.d/password-auth',
      }

      $pam_module  = $facts['os']['architecture'] ? {
        /(i386|i686)/ => '/lib/security/pam_duo.so',
        'x86_64'      => '/lib64/security/pam_duo.so',
        default       => '/lib64/security/pam_duo.so',
      }

      include duo_unix::yum
      include duo_unix::generic
    }
    'Debian', 'Ubuntu': {
      $duo_package = 'duo-unix'
      $ssh_service = 'ssh'
      $gpg_file    = '/etc/apt/DEB-GPG-KEY-DUO'
      $pam_file    = '/etc/pam.d/common-auth'

      $pam_module  = $facts['os']['architecture'] ? {
        /(i386|i686)/    => '/lib/security/pam_duo.so',
        /(amd64|x86_64)/ => '/lib64/security/pam_duo.so',
        default          => '/lib64/security/pam_duo.so',
      }

      include duo_unix::apt
      include duo_unix::generic
    }
    default: {
      fail("Module ${module_name} does not support ${facts['os']['name']}")
    }
  }

  if $usage == 'login' {
    include duo_unix::login
  } else {
    include duo_unix::pam
  }
}
