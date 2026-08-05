#!/usr/bin/env ruby

require "json"
require "open3"
require "yaml"

ROOT = File.expand_path("..", __dir__)

STANDARD_ROOT = File.join(ROOT, "generated", "standard-agent")
GITHUB_ROOT = File.join(ROOT, "generated", "github-agent")

AGENTS = {
  "standard" => {
    root: STANDARD_ROOT,
    settings: "settings.mcs.yml",
    instructions: "agent.mcs.yml",
    action: "actions/ClassifyIssue.mcs.yml",
    workflow: "workflows/ClassifyIssue-0d6fe1bc-4f73-4d24-97fd-d52a8df08481/workflow.json",
    metadata: "workflows/ClassifyIssue-0d6fe1bc-4f73-4d24-97fd-d52a8df08481/metadata.yml"
  },
  "github-harness" => {
    root: GITHUB_ROOT,
    settings: "settings.mcs.yml",
    instructions: "settings.mcs.yml",
    action: "actions/ClassifyIssue.mcs.yml",
    workflow: "workflows/ClassifyIssue-b28bf51a-c2b7-4f7a-af53-cfd72134b92a/workflow.json",
    metadata: "workflows/ClassifyIssue-b28bf51a-c2b7-4f7a-af53-cfd72134b92a/metadata.yml"
  }
}.freeze

def assert(condition, message)
  raise message unless condition
end

AGENTS.each do |name, files|
  root = files.fetch(:root)
  files.reject { |key, _| key == :root }.values.grep(String).each do |relative|
    path = File.join(root, relative)
    assert(File.file?(path), "#{name}: missing #{relative}")
  end

  settings = YAML.safe_load(File.read(File.join(root, files.fetch(:settings))), aliases: true)
  assert(!settings.fetch("displayName").to_s.empty?, "#{name}: displayName is empty")
  assert(!settings.fetch("schemaName").to_s.empty?, "#{name}: schemaName is empty")

  instruction_text = File.read(File.join(root, files.fetch(:instructions)))
  assert(instruction_text.include?("Classify Issue"), "#{name}: instructions do not reference Classify Issue")

  action = YAML.safe_load(File.read(File.join(root, files.fetch(:action))), aliases: true)
  metadata = YAML.safe_load(File.read(File.join(root, files.fetch(:metadata))), aliases: true)
  assert(action.dig("action", "kind") == "InvokeFlowTaskAction", "#{name}: action is not a flow tool")
  assert(action.dig("action", "flowId") == metadata.fetch("workflowId"), "#{name}: action flowId mismatch")

  workflow = JSON.parse(File.read(File.join(root, files.fetch(:workflow))))
  definition = workflow.dig("properties", "definition")
  trigger = definition.dig("triggers", "manual")
  response = definition.dig("actions", "Respond_to_the_agent")

  assert(trigger&.fetch("kind") == "Skills", "#{name}: missing agent-call trigger")
  assert(response&.fetch("kind") == "Skills", "#{name}: missing agent response")
  assert(workflow.dig("properties", "connectionReferences") == {}, "#{name}: simple workflow must not require connectors")

  properties = response.dig("inputs", "schema", "properties")
  %w[category priority summary needsHumanReview].each do |output|
    assert(properties.key?(output), "#{name}: missing workflow output #{output}")
  end

  puts "OK #{name}: agent + workflow + tool link"
end

standard_settings = YAML.safe_load(
  File.read(File.join(STANDARD_ROOT, "settings.mcs.yml")),
  aliases: true
)
assert(
  standard_settings.dig("configuration", "settings", "GenerativeActionsEnabled") == false,
  "standard: generative actions must be disabled"
)
assert(
  standard_settings.dig("configuration", "aISettings", "useModelKnowledge") == false,
  "standard: model knowledge must be disabled"
)

classic_topic_path = File.join(STANDARD_ROOT, "topics", "ClassifyIssue.mcs.yml")
assert(File.file?(classic_topic_path), "standard: explicit Classify Issue topic missing")
classic_topic = YAML.safe_load(File.read(classic_topic_path), aliases: true)
classic_actions = classic_topic.dig("beginDialog", "actions")
assert(
  classic_actions.any? { |action| action["kind"] == "InvokeFlowAction" },
  "standard: explicit topic does not invoke the workflow"
)
puts "OK standard: non-GenAI explicit topic"

test_cases = YAML.safe_load(File.read(File.join(ROOT, "shared", "test-cases.yaml")), aliases: true)

test_cases.fetch("cases").each do |test_case|
  input = test_case.fetch("input")
  command = [
    "ruby",
    File.join(ROOT, "tools", "triage_cli.rb"),
    "--title",
    input.fetch("issueTitle"),
    "--body",
    input.fetch("issueBody")
  ]
  stdout, stderr, status = Open3.capture3(*command)
  assert(status.success?, "#{test_case.fetch('id')}: CLI failed: #{stderr}")
  result = JSON.parse(stdout)
  expected = test_case.fetch("expected")

  assert(result["category"] == expected["type"], "#{test_case.fetch('id')}: category mismatch") if expected["type"]
  assert(result["priority"] == expected["priority"], "#{test_case.fetch('id')}: priority mismatch") if expected["priority"]
  assert(expected["priorityAnyOf"].include?(result["priority"]), "#{test_case.fetch('id')}: priority not allowed") if expected["priorityAnyOf"]
  if expected.key?("needsHumanReview")
    assert(result["needsHumanReview"] == expected["needsHumanReview"], "#{test_case.fetch('id')}: human review mismatch")
  end

  puts "OK test #{test_case.fetch('id')}"
end

packages = {
  "standard agent package" => File.join(ROOT, "dist", "TriageStandardAgent.zip"),
  "GitHub harness agent package" => File.join(ROOT, "dist", "TriageGitHubHarnessAgent.zip"),
  "workflow package" => File.join(ROOT, "dist", "triage-workflows.zip"),
  "skill package" => File.join(ROOT, "dist", "issue-triage-skill.zip")
}

packages.each do |name, path|
  next unless File.exist?(path)

  _stdout, stderr, status = Open3.capture3("unzip", "-t", path)
  assert(status.success?, "#{name}: invalid ZIP: #{stderr}")
  puts "OK #{name}"
end

workflow_entries, _stderr, workflow_status = Open3.capture3(
  "unzip",
  "-Z1",
  File.join(ROOT, "dist", "triage-workflows.zip")
)
if workflow_status.success?
  assert(workflow_entries.include?("ClassifyIssueStandard"), "workflow package: Standard workflow missing")
  assert(workflow_entries.include?("ClassifyIssueGitHubHarness"), "workflow package: GitHub harness workflow missing")
end

puts "All local checks passed."
