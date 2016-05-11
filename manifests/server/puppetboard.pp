class bsl_puppet::server::puppetboard(
  $admin_user = 'admin',
  $admin_pass = 'admin',
  $www_hostname = 'puppet',
)  {
  include '::apache'
  include '::apache::mod::wsgi'

  class { '::puppetboard':
    puppetdb_host => 'puppet',
  }

  class { '::puppetboard::apache::vhost':
    vhost_name => $www_hostname,
    port       => 80,
  }

  Apache::Vhost <| docroot == "$::puppetboard::apache::vhost::docroot" |> {
    directories => [
      {
        path                => "$::puppetboard::apache::vhost::docroot",
        auth_type           => 'basic',
        auth_name           => 'puppetboard',
        auth_user_file      => "${::puppetboard::apache::vhost::basedir}/htpasswd",
        auth_require        => 'valid-user',
        auth_basic_provider => file,
      }
    ],
  }

  httpauth { "${admin_user}":
    file      =>  "${::puppetboard::apache::vhost::basedir}/htpasswd",
    password  => "${admin_pass}",
    realm     => 'puppetboard',
    mechanism => basic,
    ensure    => present,
  }
  ->
  file { "${::puppetboard::apache::vhost::basedir}/htpasswd":
    owner => $::apache::user,
  }
}