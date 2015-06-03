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
        ensure => latest,
        require => Class['server']
    }

    # The shell of www-data
    -> exec { 'change www-data shell':
      onlyif => "test `cat /etc/passwd | grep www-data | awk -F ':' '{ print \$7 }'` != '/bin/bash'",
      command => 'chsh -s /bin/bash www-data'
    }

    # Generate certificates
    -> file { "/etc/apache2/ssl":
      ensure => directory,
    }
    -> exec { "key file certificate":
      command => "openssl genrsa -out ${server_name}.key 2048",
      cwd => "/etc/apache2/ssl",
      creates => "/etc/apache2/ssl/${server_name}.key",
      notify => Class['apache::service'],
    }
    -> exec { "cert file certificate":
      command => "openssl req -new -x509 -key ${server_name}.key -out ${server_name}.cert -days 3650 -subj /CN=${server_name}",
      cwd => "/etc/apache2/ssl",
      creates => "/etc/apache2/ssl/${server_name}.cert",
      notify => Class['apache::service'],
    }

    # create the log directory
    file { "logs":
        ensure => "directory",
        path    => "/var/log/$server_name",
        owner  => "root",
        group  => "root",
        mode   => 777,
    }

  file { "logs-extension":
        ensure => "directory",
        path    => "/var/log/extension.vm",
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

    # create the subfolder www in the document root
    file { "document_root_www":
        ensure => "directory",
        path    => "$document_root/www",
        owner  => "vagrant",
        group  => "vagrant",
        mode   => 777,
    }

    # Disable 000-default vhost
    exec { "Disable 000-default":
      onlyif => "test -f /etc/apache2/sites-enabled/000-default.conf",
      command => "a2dissite 000-default",
      require => [ Package['apache2'] ],
      notify => Class['apache::service'],
    }

    # Create the vhost
    -> file { "virtual-host":
      path => "/etc/apache2/sites-available/$server_name.conf",
      ensure => present,
      content => template("apache/vhost"),
      notify => Class['apache::service'],
    }

    # Create the vhost
    -> file { "virtual-host-extension":
      path => "/etc/apache2/sites-available/extension.vm.conf",
      ensure => present,
      content => template("apache/extension-vhost"),
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
      command => "a2ensite $server_name.conf",
      creates => "/etc/apache2/sites-enabled/$server_name.conf",
      require => [ Package['apache2'], File['virtual-host'] ],
      notify => Class['apache::service'],
    }

    # Enable mod rewrite
    exec { 'enable mod rewrite':
      onlyif => 'test `apache2ctl -M 2> /dev/null | grep rewrite | wc -l` -ne 1',
      command => 'a2enmod rewrite',
      require => Package['apache2'],
    } ~> Service['apache2']

    exec { 'enable mod ssl':
      onlyif => 'test `apache2ctl -M 2> /dev/null | grep ssl | wc -l` -ne 1',
      command => 'a2enmod ssl',
      require => Package['apache2'],
    } ~> Service['apache2']

    exec { 'enable mod headers':
      onlyif => 'test `apache2ctl -M 2> /dev/null | grep headers | wc -l` -ne 1',
      command => 'a2enmod headers',
      require => Package['apache2'],
    } ~> Service['apache2']

    # Add www-data to vagrant group
    exec { "Add www-data to vagrant group":
      command => 'adduser www-data vagrant',
      require => Package['apache2'],
    }
}