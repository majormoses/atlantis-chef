# frozen_string_literal: true

# setup atlantis user/group
atlantis_user_group_setup 'atlantis' do
  username 'atlantis'
  groupname 'atlantis'
end

# drop down atlantis config
# create a local hash for testing
config_vars = {
  'atlantis-url'          => 'https://localhost:4141',
  'allow-repo-config'     => false,
  'gh-user'               => 'my-atlantis-bot',
  'gh-token'              => 'A_GITHUB_TOKEN',
  'gh-webhook-secret'     => 'A_GITHUB_WEBHOOK_SECRET',
  'log-level'             => 'info',
  'port'                  => 4141,
  'repo-allowlist'        => %w(org/repo1 org/repo2).join(','),
}

atlantis_config 'atlantis' do
  template_variables config_vars
end

# install required dependencies
package %w(unzip git)

atlantis_installer 'atlantis' do
  version '0.15.0'
  checksum 'a236e7c9df159f8787b143c670f1899dd4bc4349f23ed696468600280fa1266e'
end

terraform_installer 'terraform' do
  version '0.13.3'
  checksum '35c662be9d32d38815cde5fa4c9fa61a3b7f39952ecd50ebf92fd1b2ddd6109b'
end

terragrunt_repo_config = {
  'repos' => [
    {
      'id' => '/.*/',
      'allow_custom_workflows' => false,
      'allowed_overrides' => [
        'workflow',
      ],
    },
  ],
  'workflows' => {
    # Terragrunt workflow - https://terragrunt.gruntwork.io/
    'terragrunt' => {
      'plan' => {
        'steps' => [
          {
            'env' => {
              'name' => 'TERRAGRUNT_TFPATH',
              'command' => "echo \"/opt/atlantis/data/bin/terraform\${ATLANTIS_TERRAFORM_VERSION}\"",
            },
          },
          {
            'run' => 'terragrunt plan -no-color -out=$PLANFILE 2>&1 | awk \'BEGIN{flag=0} { if (!flag && /------------------------------------------------------------------------/){ flag=1; buf="" } else {buf = buf $0 ORS} } END { printf "%s", buf; }\'',
          },
        ],
      },
      'apply' => {
        'steps' => [
          {
            'env' => {
              'name' => 'TERRAGRUNT_TFPATH',
              'command' => "echo \"/opt/atlantis/data/bin/terraform\${ATLANTIS_TERRAFORM_VERSION}\"",
            },
          },
          {
            'run' => 'terragrunt apply -no-color $PLANFILE 2>&1 | awk \'BEGIN{flag=0} { if (!flag && /------------------------------------------------------------------------/){ flag=1; buf="" } else {buf = buf $0 ORS} } END { printf "%s", buf; }\'',
          },
        ],
      },
    },
  },
}

atlantis_config 'repo-config' do
  atlantis_config_file 'repos.yaml'
  template_variables terragrunt_repo_config
end

terragrunt_installer 'terragrunt' do
  version '0.25.4'
  checksum '3b033389977ca6e7d10bad10514f22fa767c85b76db92befe83e67bafa2c8413'
end

if node['platform_version'] == '14.04'
  atlantis_service_upstart 'atlantis'
else
  atlantis_service_systemd 'atlantis' do
    use_exec_stop false
    environment ['John=Basement', 'Tom=Roof']
  end
end
