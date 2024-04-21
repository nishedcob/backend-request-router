
MEMORY=10240
CPUS=4

## help | show this help command
help: SHELL=/bin/bash
help: Makefile
	@sed -n 's/^## //p' <(cat $^) | column -ts '|'

## mK8s | prepare universal-minikube git-submodule for use
mK8s: VERSION=$$(jq -r '.version' .universal-minikube)
mK8s:
	if [ ! -d $@ ]; then git submodule add git@github.com:nishedcob/universal-minikube.git mK8s ; fi
	git submodule update --init --checkout -- $@
	cd $@ ; echo "Checking out $(VERSION) ..."; git fetch ; git checkout $(VERSION)

## bootstrap_mK8s | bootstrap universal-minikube
bootstrap_mK8s: SHELL=/bin/bash
bootstrap_mK8s:
	$(MAKE) -B mK8s
	cd mK8s ; $(MAKE) minikube
	minikube config set memory $(MEMORY)
	minikube config set cpus $(CPUS)
	cd mK8s ; $(MAKE) start_minikube
	while read -r line ; do \
		echo "Installing '$${line}' ..." ; \
		cd mK8s ; $(MAKE) $$line ; \
	done < <(jq -r '.plugins[]' .universal-minikube)

## bootstrap_mock_apps | bootstrap mock applications
bootstrap_mock_apps: SHELL=/bin/bash
bootstrap_mock_apps:
	kubectl apply -k k8s/envs/dev
	kubectl apply -k k8s/envs/stg
	kubectl apply -k k8s/envs/prod
