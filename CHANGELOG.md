# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format located [here](https://github.com/sensu-plugins/community/blob/master/HOW_WE_CHANGELOG.md)

## [Unreleased]

## [0.1.0] - 2018-08-29

### Added

- repo skel, misc project helpers (@majormoses)
- local and `travis-ci` testing: lint + integration (@majormoses)
- helper libraries to make it easy to download from `github` + `hashicorp` releases (@majormoses)
- new resource `atlantis_config` to manage the `atlantis` server config file (@majormoses)
- new resource `atlantis_installer` to install or remove `atlantis` (@majormoses)
- new resource `atlantis_service_systemd` to create or remove a `systemd` unit file for managing the `atlantis`  service (@majormoses)
- new resource `atlantis_service_upstart` to create or remove an `upstart` config for managing the `atlantis` service (@majormoses)
- new resource `atlantis_terrform_installer` to install or remove `terraform` for use with atlantis (@majormoses)
- new resource `atlantis_user_group_setup` which sets up or removes users, groups, and directories for atlantis service to use (@majormoses)
- use Apache 2 license (@majormoses)


[Unreleased]: https://github.com/majormoses/atlantis-chef/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/majormoses/atlantis-chef/comapre/40189cb9ae94bd6dadfc312856a98e224a7c839f...0.1.0
