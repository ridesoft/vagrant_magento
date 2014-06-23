class server () {

    exec { "update":
        path    => "/bin:/usr/bin",
        command => "apt-get update",
    }

    package { ["curl", "tidy", "vim", "zip", "libsqlite3-dev"] :
          ensure  => latest,
          require => Exec['update'],
    }
}