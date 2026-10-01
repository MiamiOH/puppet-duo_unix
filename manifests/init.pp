# == Class: duo_unix
#
# Core class for duo_unix module
#
# === Authors
#
# Mark Stanislav <mstanislav@duosecurity.com>
#
# @summary Core class for duo_unix module
#
# @param package_version The package version to install (e.g., 'installed', 'latest', or a specific version).
# @param repo_uri The base URI for the Duo repository.
# @param ikey Duo integration key.
# @param skey Duo secret key.
# @param host Duo API host.
# @param group Optional group restriction for Duo authentication.
# @param http_proxy Optional HTTP proxy configuration.
# @param usage The usage type for duo_unix, either 'login' or 'pam'.
# @param fallback_local_ip Fallback local IP setting ('yes' or 'no').
# @param failmode Failure mode ('safe' or 'secure').
# @param pushinfo Push info setting ('yes' or 'no').
# @param autopush Auto push setting ('yes' or 'no').
# @param motd MOTD display setting ('yes' or 'no').
# @param prompts Number of prompts.
# @param accept_env_factor Accept environment factor setting ('yes' or 'no').
# @param manage_ssh Whether to manage openssh-server package and sshd configuration.
# @param manage_pam Whether to manage PAM configuration.
# @param pam_unix_control PAM control flag for unix module.
class duo_unix (
  String $package_version,
  String $repo_uri,
  String $ikey,
  String $skey,
  String $host,
  Optional[String] $group = undef,
  Optional[String] $http_proxy = undef,
  Optional[Enum['login', 'pam']] $usage = undef,
  String $fallback_local_ip = 'no',
  String $failmode = 'safe',
  String $pushinfo = 'no',
  String $autopush = 'no',
  String $motd = 'no',
  String $prompts = '3',
  String $accept_env_factor = 'no',
  Boolean $manage_ssh = true,
  Boolean $manage_pam = true,
  String $pam_unix_control = 'requisite',
) {
  if $ikey == '' or $skey == '' or $host == '' {
    fail('ikey, skey, and host must all be defined')
  }

  if $usage == undef {
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
