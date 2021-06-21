resource_name :atlantis_service_upstart
provides :atlantis_service_upstart
unified_mode true

property :atlantis_service_template_variables, Hash, default: {
  atlantis_user: 'atlantis',
  atlantis_bin_location: '/usr/local/bin/atlantis',
  atlantis_config_name: 'atlantis.yaml',
  atlantis_home: '/opt/atlantis',
  timeout_stop_sec: 5,
}
property :atlantis_service_template_cookbook, String, default: 'atlantis'
property :atlantis_user, String, default: 'atlantis'

default_action :setup

action :setup do
  template 'atlantis.upstart.conf' do
    cookbook new_resource.atlantis_service_template_cookbook
    path '/etc/init/atlantis.conf'
    action :create
    variables(vars: new_resource.atlantis_service_template_variables)
  end

  service 'atlantis' do
    action [:enable, :start]
    provider Chef::Provider::Service::Upstart
  end
end

action :remove do
  file '/etc/init/atlantis.conf' do
    action :delete
  end
end
