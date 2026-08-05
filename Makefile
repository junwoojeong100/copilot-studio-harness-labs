.PHONY: verify demo pack

verify:
	ruby tools/verify.rb

demo:
	ruby tools/triage_cli.rb --json examples/issue.json

pack:
	bash scripts/pack-agents.sh
	bash scripts/pack-workflows.sh

