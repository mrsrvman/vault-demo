Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin' }

import 'classes/*'

node default {

  ensure_packages(['jq'])
  class { 'consul':
    config_hash => {
      'datacenter'  => 'dc1',
      'data_dir'    => '/opt/consul',
      'client_addr' => '0.0.0.0',
      'log_level'   => 'INFO',
      'node_name'   => $::hostname,
      'bind_addr'   => $::ipaddress_eth1,
      'server'      => false,
      'retry_join'  => [hiera('join_addr')],
    }
  } ->
  class { 'vault':
  }

  ::consul::service { 'vault':
    port => 8200,
    checks  => [{
      script   => "curl -s ${::ipaddress_eth1}:8200/v1/sys/seal-status | jq .sealed | grep false > /dev/null",
      interval => '5s'
    }],
  }

}
