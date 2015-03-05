class tools::z {

  exec { "install z.sh":
    cwd     => "/usr/local/bin",
    creates => "/usr/local/bin/z.sh",
    command => "wget --no-check-certificate https://raw.github.com/rupa/z/master/z.sh -O /usr/local/bin/z.sh",
    require => [ Package['php5'] ],
  }

  -> exec { "add z.sh to .bashrc":
    cwd     => "/usr/local/bin",
    command => "echo '. /usr/local/bin/z.sh' >> /home/vagrant/.bashrc",
  }

}