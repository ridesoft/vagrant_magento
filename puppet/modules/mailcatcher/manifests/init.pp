class mailcatcher () {

$modules = [
"ruby", "ruby1.9.1-dev", "build-essential"
]
package { $modules :
  ensure => latest,
  require => Exec["update"],
}

  package { "mailcatcher":
    ensure => latest,
    provider => gem,
    require => [ Package['libsqlite3-dev'], Class["php"] ]
  }
}