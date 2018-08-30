# create some global variables
CHEF_METADATA_FILE := metadata.rb
CURRENT_COOKBOOK_VERSION := $(shell egrep "^version\s+" $(CHEF_METADATA_FILE) | awk '{ print $$2}' | tr -d \')


# TODO: come back and review the versioning
# bumpmajor: ## bumps version for a major release
# 	bundle exec semver inc major

# bumpminor: ## bumps version for a minor release
# 	bundle exec semver inc minor

# bumppatch: ## bumps version for path/hotfix release
# 	bundle exec semver inc patch

foodtest: ## run foodcritic
	bundle exec foodcritic -t ~FC019 -t ~FC052 .

gittag: ## tags the repo with the version in `metadata.rb`
	git tag -a $(CURRENT_COOKBOOK_VERSION) -m "tagging $(CURRENT_COOKBOOK_VERSION) for release"
	@echo git push origin $(CURRENT_COOKBOOK_VERSION)


gemdeps: ## install the gem dependencies locally in vendor/bundle
	bundle install --path vendor/bundle

rubotest: ## run cookstyle with our config
	bundle exec cookstyle --display-cop-names --extra-details --display-style-guide .

rubofix: ## run cookstyle and attempt to auto correct
	bundle exec cookstyle --display-cop-names --extra-details --display-style-guide --auto-correct

travis: rubotest foodtest gemdeps ## run all tets that should be run in travis
	# if INSTANCE ENV var is not specified it should test all of them
	bundle exec kitchen test ${INSTANCE}

# Do not sort anything below here
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: help
