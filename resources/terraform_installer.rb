# frozen_string_literal: true
include AtlantisCookbook::Helpers

resource_name :terraform_installer
provides :terraform_installer
unified_mode true

property :append_version_to_file, [true, false], default: false
property :checksum, String, regex: /^[a-zA-Z0-9]{64}$/, default: '35c662be9d32d38815cde5fa4c9fa61a3b7f39952ecd50ebf92fd1b2ddd6109b'
property :download_base_url, String, default: 'https://releases.hashicorp.com'

property :group, [String, Integer], default: 'atlantis'
property :owner, String, default: 'atlantis'
property :mode, [String, Integer], default: '0755'

property :version, String, default: '0.13.3'

default_action :install

# actions
action :install do
  # install terraform
  ark 'terraform' do
    url hashicorp_download_url(
      new_resource.download_base_url,
      'terraform',
      new_resource.version
    )
    version new_resource.version
    checksum new_resource.checksum unless new_resource.checksum.nil?
    prefix_root '/opt/atlantis'
    prefix_home '/opt/atlantis'
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
    if new_resource.append_version_to_file
      has_binaries ["terraform#{new_resource.version}"]
    else
      has_binaries ['terraform']
    end
    strip_components 0
  end
end

action :remove do
  file '/usr/local/bin/terraform' do
    action :delete
  end
end
