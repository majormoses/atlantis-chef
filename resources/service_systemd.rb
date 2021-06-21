# frozen_string_literal: true
include AtlantisCookbook::Helpers

resource_name :atlantis_service_systemd
provides :atlantis_service_systemd
unified_mode true

property :atlantis_bin_location, String, default: '/usr/local/bin/atlantis'
property :atlantis_config_name, String, default: 'atlantis.yaml'
property :atlantis_home, String, default: '/opt/atlantis'
property :timeout_stop_sec, [Integer, String], default: 5
# The exit status code 143 = 128 + 15 = default terminate by system when the application doesn't have one
property :atlantis_success_exit_status, [Integer, String], default: 143
property :atlantis_user, String, default: 'atlantis'
property :atlantis_group, String, default: 'atlantis'
property :use_exec_stop, [true, false], default: true
property :environment, [String, Array]
property :environment_file, [String, Array]

default_action :setup

action :setup do
  service_content = {
    'Unit' => {
      'Description' => 'Atlantis',
      'After' => 'network-online.target',
    },
    'Service' => {
      'Type' => 'simple',
      'ExecStart' => "#{new_resource.atlantis_bin_location} server --config #{new_resource.atlantis_home}/#{new_resource.atlantis_config_name}",
      'SuccessExitStatus' => new_resource.atlantis_success_exit_status.to_i, # support strings
      'User' => new_resource.atlantis_user,
      'Group' => new_resource.atlantis_group,
      'Restart' => 'always',
    },
    'Install' => {
      'WantedBy' => 'multi-user.target',
    },
  }
  service_content['Service']['ExecStop'] = '/bin/kill $MAINPID' if new_resource.use_exec_stop
  service_content['Service']['TimeoutStopSec'] = new_resource.timeout_stop_sec.to_i if new_resource.use_exec_stop
  service_content['Service']['Environment'] = new_resource.environment if new_resource.environment
  service_content['Service']['EnvironmentFile'] = new_resource.environment_file if new_resource.environment_file

  systemd_unit 'atlantis.service' do
    content(service_content)
    action [:create, :enable, :start]
  end
end

action :remove do
  systemd_unit 'atlantis.service' do
    action [:stop, :disable, :delete]
  end
end
