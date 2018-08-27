# frozen_string_literal: true

resource_name :atlantis_service_systemd

include AtlantisCookbook::Helpers

property :atlantis_bin_location, String, default: '/usr/local/bin/atlantis/atlantis'
property :atlantis_config_name, String, default: 'atlantis.yaml'
property :atlantis_group, String, default: 'atlantis'
property :atlantis_home, String, default: '/etc'
property :timeout_stop_sec, [Integer, String ], default: 5
# The exit status code 143 = 128 + 15 = default terminate by system when the application doesn't have one
property :atlantis_success_exit_status, [Integer, String], default: 143
property :atlantis_user, String, default: 'atlantis'

default_action :setup

action :setup do
  systemd_unit 'atlantis.service' do
    content ({
      'Unit' => {
        'Description' => 'Atlantis',
        'After' => 'network.target',
      },
      'Service' => {
        'Type' => 'simple',
        'ExecStart' => "#{new_resource.atlantis_bin_location} server --config #{new_resource.atlantis_home}/#{new_resource.atlantis_config_name}",
        'ExecStop' => '/bin/kill $MAINPID',
        'TimeoutStopSec' => new_resource.timeout_stop_sec.to_i,
        'SuccessExitStatus' => new_resource.atlantis_success_exit_status.to_i, # support strings
        'User' => new_resource.atlantis_user,
        'Group' => new_resource.atlantis_group,
        'Environment' => 'PATH=$PATH:/usr/local/bin/terraform',
        'Restart' => 'always',
      },
      'Install' => {
        'WantedBy' => 'multi-user.target',
      },
    })
    action [:create, :enable, :start]
  end
end

action :remove do
  systemd_unit 'atlantis.service' do
    action [:stop, :disable, :delete]
  end
end
