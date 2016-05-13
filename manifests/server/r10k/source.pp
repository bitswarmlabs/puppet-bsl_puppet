define bsl_puppet::server::r10k::source(
  $provider = 'github',
  $provider_server_url = 'https://api.github.com',
  $disable_ssl_verify = false,
  $remote,
  $basedir = $::environmentpath,
  $prefix = true,
  $manage_deploy_key = 'true',
  $manage_webhook = 'false',
  $webhook_url,
  $project,
  $key_type = 'rsa',
  $key_length = '1024',
  $key_comment = "puppet-${name}-insecure",
) {
  $deploy_key_name = "$key_comment@${::fqdn}"

  include '::bsl_puppet::server::r10k'

  $key_filename = inline_template('<%= scope.lookupvar("::puppet::server_dir") %>/ssh/id_<%= @provider %>_<%= @project.gsub(/(\/|\-)/, "_") %>_<%= @key_type %>')
  $deploy_key = "${key_filename}.pub"

  $pseudo_hostname = inline_template('<%= @project.gsub(/(\/|\_)/, "-") %>.<%= @provider %>')

  if ! defined(File[$basedir]) {
    file { $basedir:
      ensure => directory,
      owner => $::puppet::server_user,
      group => $::puppet::server_group,
    }
  }

  if !empty($bsl_puppet::server::r10k::github_api_token) {
    # https://github.com/settings/tokens/new and
    # https://github.com/abrader/abrader-gms
    # http://github.com/maestrodev/puppet-ssh_keygen
    if str2bool($manage_deploy_key) {
      include '::bsl_puppet::server::ssh_keys'

      Class['::bsl_puppet::server::ssh_keys']
      ->
      exec { "ssh_keygen-${name}":
        command   => "ssh-keygen -v -t ${key_type} -b ${key_length} -f '${$key_filename}' -N '' -C '${key_comment}'",
        creates   => $key_filename,
        logoutput => true,
        user      => $::puppet::server_user,
        path      => '/usr/bin:/bin',
      }
      ->
      ssh_config { "Hostname for ${name}":
        host      => "${pseudo_hostname} github.com",
        key       => 'Hostname',
        value     => "github.com",
        ensure    => present,
      }
      ->
      ssh_config { "IdentityFile for ${name}":
        host      => "${pseudo_hostname} github.com",
        key       => 'IdentityFile',
        value     => $key_filename,
        ensure    => present,
      }
      ->
      git_deploy_key { $deploy_key_name:
        ensure       => present,
        path         => $deploy_key,
        token        => $bsl_puppet::server::r10k::github_api_token,
        project_name => $project,
        server_url   => $provider_server_url,
        provider     => $provider,
      }
    }

    if str2bool($manage_webhook) {
      include 'bsl_puppet::server::r10k::webhook'

      Class['bsl_puppet::server::r10k::webhook']
      ->
      git_webhook { $name :
        ensure             => present,
        token              => $bsl_puppet::server::r10k::github_api_token,
        webhook_url        => $webhook_url,
        project_name       => $project,
        server_url         => $provider_server_url,
        disable_ssl_verify => $disable_ssl_verify,
        provider           => $provider,
      }
    }
  }
}