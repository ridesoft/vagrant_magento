class mysql::install ( $db_root_password, $db_name, $db_user, $db_password ) {

# MySQL server & client
package { "mysql-server":
  ensure => latest,
  require => [ Class['server'], File['/etc/mysql/my.cnf'] ],
  notify => Service['mysql'],
}

-> package { "mysql-client":
  ensure => latest,
}

file { "/etc/mysql":
  ensure => directory,
}

-> file { "/etc/mysql/my.cnf":
  ensure => file,
  source => "puppet:///modules/mysql/my.cnf",
  owner => "root",
  group => "root",
  notify => Service['mysql'],
}

# Stop mysql
exec { "stop mysql":
  refreshonly => true,
  command => "service mysql stop"
}

# Setup the root password
exec { "setup the root password":
  path => "/usr/bin",
  unless => "mysqladmin -uroot -p${db_root_password} status",
  command => "mysqladmin -uroot password ${db_root_password}",
  require => [ Package['mysql-client'], Service['mysql'], Package['mysql-server'] ],
}

# ~/.my.cnf
-> file { "/root/.my.cnf":
  ensure => present,
  content => template("mysql/.my.cnf"),
}
}