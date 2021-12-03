

# This targets reads default Falco rules files in the order stablished by default in falco.yaml
# and adds a list of those in customized/*.yaml
validate-local:
	docker run --rm -it \
		-v "$$(pwd)/falco/rules":/falco/rules \
		-v "$$(pwd)/customized":/customized \
		falcosecurity/falco-no-driver:latest \
		falco -V /falco/rules/falco_rules.yaml \
			-V /falco/rules/falco_rules.local.yaml \
			-V /falco/rules/k8s_audit_rules.yaml \
			`ls customized/*.yaml | xargs -I {} echo -V {} | xargs`

# Create resources

start-minikube:
	minikube start

create-configmap:
	kubectl create configmap main-falco-rules -n falco \
	--from-file=falco/rules/falco_rules.yaml \
	--from-file=falco/rules/k8s_audit_rules.yaml

deploy-falco: create-configmap
	kubectl create ns falco ||:
	helm repo add falcosecurity https://falcosecurity.github.io/charts
	helm repo update
	helm install falco falcosecurity/falco -n falco \
		-f helm-rules-values.yaml

create-rule-update:
	scripts/create_rule_update_k8s.sh

# Update resources

update-falco: create-rule-update 
	helm upgrade falco falcosecurity/falco -n falco \
  		-f tmp/rule_update_falco.yaml \
  		--wait --timeout 40s \
		--set=pullPolicy=IfNotPresent

update-configmap:
	kubectl create configmap main-falco-rules -n falco \
	--from-file=falco/rules/falco_rules.yaml \
	--from-file=falco/rules/k8s_audit_rules.yaml \
	--dry-run=client -o yaml | kubectl replace -f -

# Interactive utils

wait-falco:
	kubectl rollout status daemonset -n falco falco --timeout 60s

logs-falco:
	kubectl logs daemonset/falco -f

# Destroy resources

delete-configmap:
	kubectl delete cm main-falco-rules -n falco

remove-falco: delete-configmap
	helm uninstall falco -n falco

delete-minikube:
	minikube delete

# Combined commands

launch: validate-local deploy-falco wait-falco logs-falco

update: update-configmap update-falco

destroy: remove-falco