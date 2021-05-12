# frozen_string_literal: true
include AtlantisCookbook::Helpers

resource_name :terragrunt_installer
provides :terragrunt_installer
unified_mode true

property :checksum, String, regex: /^[a-zA-Z0-9]{64}$/, default: '3b033389977ca6e7d10bad10514f22fa767c85b76db92befe83e67bafa2c8413'
property :download_base_url, String, default: 'https://github.com/gruntwork-io/terragrunt/releases/download'

property :group, [String, Integer], default: 'root'
property :owner, [String, Integer], default: 'root'
property :mode, [String, Integer], default: '0755'

property :version, String, default: '0.25.4'

default_action :install

action :install do
  remote_file '/usr/local/bin/terragrunt' do
    source terragrunt_github_download_url(new_resource.download_base_url, new_resource.version)
    checksum new_resource.checksum unless new_resource.checksum.nil?

    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
  end
end

action :remove do
  file '/usr/local/bin/terragrunt' do
    action :delete
  end
end
