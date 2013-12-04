class apache::install ( $server_name, $document_root) {

    Exec {
        path => [
            '/usr/local/bin',
            '/opt/local/bin',
            '/usr/bin',
            '/usr/sbin',
            '/bin',
            '/sbin'
        ],
    }

    # Install the package
    package { "apache2":
        name   => "apache2",
        ensure => latest
    }

    # create the log directory
    file { "logs":
        ensure => "directory",
        path    => "/var/log/$server_name",
        owner  => "root",
        group  => "root",
        mode   => 777,
    }

    # create the document root
    file { "document_root":
        ensure => "directory",
        path    => "$document_root",
        owner  => "vagrant",
        group  => "vagrant",
        mode   => 777,
    }

    # Disable 000-default vhost
    exec { "Disable 000-default":
      onlyif => "test -f /etc/apache2/sites-enabled/000-default",
      command => "a2dissite 000-default",
      require => [ Package['apache2'] ],
      notify => Class['apache::service'],
    }

    # Create the vhost
    -> file { "virtual-host":
      path => "/etc/apache2/sites-available/$server_name",
      ensure => present,
      content => template("apache/vhost"),
      notify => Class['apache::service'],
    }

    # Create the phpinfo-file
    -> file { "php-info":
      path => "$document_root/info.php",
      ensure => present,
      content => template("apache/info"),
      notify => Class['apache::service'],
    }

    # Enable the virtualhost
    exec { "Enable the virtualhost":
      command => "a2ensite $server_name",
      creates => "/etc/apache2/sites-enabled/$server_name",
      require => [ Package['apache2'], File['virtual-host'] ],
      notify => Class['apache::service'],
    }

    # Enable mod rewrite
    exec { 'enable mod rewrite':
      onlyif => 'test `apache2ctl -M 2> /dev/null | grep rewrite | wc -l` -ne 1',
      command => 'a2enmod rewrite',
      require => Package['apache2'],
    } ~> Service['apache2']

    # Add www-data to vagrant group
    exec { "Add www-data to vagrant group":
      command => 'adduser www-data vagrant',
      require => Package['apache2'],
    }
}