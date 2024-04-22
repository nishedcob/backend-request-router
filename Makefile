
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
bootstrap_mock_apps: bootstrap_mK8s
	kubectl apply -k k8s/envs/dev
	kubectl apply -k k8s/envs/stg
	kubectl apply -k k8s/envs/prod

## build_app | build application
build_app: SHELL=/bin/bash
build_app:
	docker build -t backend-request-router:latest src/

## push_app | push application
push_app: SHELL=/bin/bash
push_app: build_app bootstrap_mK8s
	REGISTRY_PORT=$$((minikube service -n kube-system registry --url | sed 's/http:\/\/127.0.0.1://' | head -n 1) &) \
		docker tag backend-request-router:latest registry:$$(REGISTRY_PORT)/backend-request-router:latest ; \
		docker push registry:$$(REGISTRY_PORT)/backend-request-router:latest

## bootstrap_app | bootstrap application
bootstrap_app: SHELL=/bin/bash
bootstrap_app: bootstrap_mock_apps push_app
	kubectl apply -f k8s/ingress_rules
