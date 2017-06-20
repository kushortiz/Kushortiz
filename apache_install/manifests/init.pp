include stdlib

class apache_install () {

include ::apache_repo

exec { 'mkdir /apps/Binaries':
  creates => '/apps/Binaries',
  user    => "$::apache_repo::environment_params::apache_user",
  group   => "$::apache_repo::environment_params::apache_group",
  path    => ['/bin','/usr/bin', '/usr/sbin',],
}

exec { 'mkdir /apps/apache':
  creates => '/apps/apache',
  user    => "$::apache_repo::environment_params::apache_user",
  group   => "$::apache_repo::environment_params::apache_group",
  path    => ['/bin','/usr/bin', '/usr/sbin',],
}

file { "download_$::apache_repo::environment_params::apache_sourcefile":
  ensure  => present,
  path    => "$::apache_repo::environment_params::apache_binaries/$::apache_repo::environment_params::apache_sourcefile",
  source  => "https://archive.apache.org/dist/httpd/$::apache_repo::environment_params::apache_sourcefile",
  replace => no,
  owner   => "$::apache_repo::environment_params::file_owner",
  group   => "$::apache_repo::environment_params::file_group",
  mode    => '0755',
}

file { "download_$::apache_repo::environment_params::apache_sourcefile_deps":
  ensure  => present,
  path    => "$::apache_repo::environment_params::apache_binaries/$::apache_repo::environment_params::apache_sourcefile_deps",
  source  => "https://archive.apache.org/dist/httpd/$::apache_repo::environment_params::apache_sourcefile_deps",
  replace => no,
  owner   => "$::apache_repo::environment_params::file_owner",
  group   => "$::apache_repo::environment_params::file_group",
  mode    => '0755',
}

exec { "tar -xvzf $::apache_repo::environment_params::apache_sourcefile":
  cwd     => "$::apache_repo::environment_params::apache_binaries",
  creates => "$::apache_repo::environment_params::apache_bindir",
  user    => "$::apache_repo::environment_params::apache_user",
  group   => "$::apache_repo::environment_params::apache_group",
  path    => ['/bin','/usr/bin', '/usr/sbin',],
}

exec { "tar -xvzf $::apache_repo::environment_params::apache_sourcefile_deps":
  cwd     => "$::apache_repo::environment_params::apache_binaries",
  creates => "$::apache_repo::environment_params::apache_bindir/srclib/apr-util",
  user    => "$::apache_repo::environment_params::apache_user",
  group   => "$::apache_repo::environment_params::apache_group",
  path    => ['/bin','/usr/bin', '/usr/sbin',],
}

exec { 'configure-apache':
  command => "$::apache_repo::environment_params::apache_bindir/configure --prefix=$::apache_repo::environment_params::apache_installdir",
  cwd     => "$::apache_repo::environment_params::apache_bindir",
  user    => "$::apache_repo::environment_params::apache_user",
  group   => "$::apache_repo::environment_params::apache_group",
  creates => "$::apache_repo::environment_params::apache_installdir/bin/apachectl",
}

exec { 'do_make':
  command => 'make',
  cwd     => "$::apache_repo::environment_params::apache_bindir",
  path    => ['/bin','/usr/bin', '/usr/sbin',],
  user    => "$::apache_repo::environment_params::apache_user",
  group   => "$::apache_repo::environment_params::apache_group",
  creates => "$::apache_repo::environment_params::apache_installdir/bin/apachectl",
}

exec { 'do_make_install':
  command => 'make install',
  cwd     => "$::apache_repo::environment_params::apache_bindir",
  path    => ['/bin','/usr/bin', '/usr/sbin',],
  user    => "$::apache_repo::environment_params::apache_user",
  group   => "$::apache_repo::environment_params::apache_group",
  creates => "$::apache_repo::environment_params::apache_installdir/bin/apachectl",
}

file { "$::apache_repo::environment_params::apache_installdir/conf/httpd.conf.orig":
  ensure  => present,
  source  => "$::apache_repo::environment_params::apache_installdir/conf/httpd.conf",
  replace => no,
  owner   => "$::apache_repo::environment_params::file_owner",
  group   => "$::apache_repo::environment_params::file_group",
  mode    => '0755',
}

file { "$::apache_repo::environment_params::apache_installdir/conf/httpd.conf":
  ensure => present,
}->
file_line { 'replace_listen_port':
  path    => "$::apache_repo::environment_params::apache_installdir/conf/httpd.conf",
  line    => 'Listen 8401',
  match   => '^Listen 80$',
  replace => true,
}

file_line { 'replace_user':
  path    => "$::apache_repo::environment_params::apache_installdir/conf/httpd.conf",
  line    => 'User webadm',
  match   => '^User daemon$',
  replace => true,
}

file_line { 'replace_group':
  path    => "$::apache_repo::environment_params::apache_installdir/conf/httpd.conf",
  line    => 'Group webadm',
  match   => '^Group daemon$',
  replace => true,
}

service { 'apache2':
  ensure  => running,
  start   => "sudo -u $::apache_repo::environment_params::apache_user $::apache_repo::environment_params::apache_installdir/bin/apachectl start",
  stop    => "sudo -u $::apache_repo::environment_params::apache_user $::apache_repo::environment_params::apache_installdir/bin/apachectl stop",
  pattern => 'httpd',
}
}
include apache_install
