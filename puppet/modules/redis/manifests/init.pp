class redis () {

  # Install package
  package { "redis-server":
    ensure => latest,
  }
  
}