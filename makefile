

# This targets reads default Falco rules files in the order stablished by default in falco.yaml
# and adds a list of those in customized/*.yaml
validate-falco-rules:
	docker run --rm -it \
		-v "$$(pwd)/falco/rules":/falco/rules \
		-v "$$(pwd)/customized":/customized \
		falcosecurity/falco-no-driver:latest \
		falco -V /falco/rules/falco_rules.yaml \
			-V /falco/rules/falco_rules.local.yaml \
			-V /falco/rules/k8s_audit_rules.yaml \
			`ls customized/*.yaml | xargs -I {} echo -V {} | xargs`

