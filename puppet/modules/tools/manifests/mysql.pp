class tools::mysql {

# Install the package
  package { "mysql-client":
    name   => "mysql-client",
    ensure => latest
  }

}