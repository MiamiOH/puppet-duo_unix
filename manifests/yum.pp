# == Class: duo_unix::yum
#
# Provides duo_unix for a yum-based environment (e.g. RHEL/CentOS)
#
# === Authors
#
# Mark Stanislav <mstanislav@duosecurity.com>
#
class duo_unix::yum {

  # Map Amazon Linux to RedHat equivalent releases
  # Map RedHat 5 to CentOS 5 equivalent releases
  if $::operatingsystem == 'Amazon' {
    $releasever = $::operatingsystemmajrelease ? {
      '2'  => '7Server',
      default => undef,
    }
    $os = 'CentOS'
  } elsif ( $::operatingsystem == 'RedHat' and
  versioncmp($::operatingsystemmajrelease, '5') == 0 ) {
    $os = 'CentOS'
    $releasever = '$releasever'
  } elsif ( $::operatingsystem == 'OracleLinux' ) {
    $os = 'RedHat'
    $releasever = '$releasever'
  } else {
    $os = $::operatingsystem
    $releasever = '$releasever'
  }

  yumrepo { 'duosecurity':
    descr    => 'Duo Security Repository',
    baseurl  => "${duo_unix::repo_uri}/${os}/${releasever}/\$basearch",
    gpgcheck => '1',
    enabled  => '1',
    require  => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-DUO'];
  }

  if $duo_unix::manage_ssh {
    package { 'openssh-server':
      ensure => installed;
    }
  }

  package {  $duo_unix::duo_package:
    ensure  => $duo_unix::package_version,
    require => [ Yumrepo['duosecurity'], Exec['Duo Security GPG Import'] ];
  }

  exec { 'Duo Security GPG Import':
    command     => '/bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-DUO',
    subscribe   => File[ $duo_unix::gpg_file ],
    refreshonly => true,
  }

}
