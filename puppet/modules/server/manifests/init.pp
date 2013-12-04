class server () {

    exec { "update":
        path    => "/bin:/usr/bin",
        command => "apt-get update",
    }

    package { ["curl", "tidy"] :
          ensure  => latest,
          require => Exec['update'],
    }
}