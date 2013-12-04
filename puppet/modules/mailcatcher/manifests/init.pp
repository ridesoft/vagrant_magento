class mailcatcher () {

$modules = [
"ruby",
"rubygems",
]
package { $modules :
  ensure => latest,
  require => Exec["update"],
}


# Install the package
package { "libsqlite3-dev":
  name => "libsqlite3-dev",
  ensure => latest
}


package { "mailcatcher":
  ensure => latest,
  provider => gem,
  require => [ Package['libsqlite3-dev'], Class["php"], Class['apache'] ],
  notify => Service["apache2"],
}

}