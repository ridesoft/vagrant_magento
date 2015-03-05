class tools::npm {

  package { 'gulp':
    provider => 'npm',
    require  => Class['nodejs']
  }

}