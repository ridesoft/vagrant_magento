class tools::deployscript {

# Create the vhost
   file { "deploy-script":
    path => "/usr/local/bin/deploy_local.sh",
    ensure => present,
    content => template("tools/deploy_local.sh")
  }

   -> exec { "chmod modman deploy-script":
     cwd     => "/usr/local/bin",
     command => "chmod +x /usr/local/bin/deploy_local.sh",
   }
}