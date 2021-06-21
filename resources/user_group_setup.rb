# frozen_string_literal: true
resource_name :atlantis_user_group_setup
provides :atlantis_user_group_setup
unified_mode true

property :username, String, default: 'atlantis'
property :groupname, String, default: 'atlantis'
property :home, String, default: '/opt/atlantis'

default_action :create

# actions
action :create do
  user new_resource.username do
    comment 'Atlantis User'
    system true
    action :create
    manage_home true # for terraform to cache plugins
    home new_resource.home
  end

  # update the dir because we cant control the permissions
  # and when created in somewhere other than /home they get
  # permissions that do not allow themselves to do stuff in
  # their own home dir
  directory new_resource.home do
    owner new_resource.username
    group new_resource.groupname
    mode '751'
    action :create
  end

  group new_resource.groupname do
    action :create
    members new_resource.username
    system true
  end
end

action :remove do
  user new_resource.username do
    action :remove
    not_if { new_resource.username == 'root' }
  end

  group new_resource.groupname do
    action :remove
    not_if { new_resource.groupname == 'root' }
  end
end
