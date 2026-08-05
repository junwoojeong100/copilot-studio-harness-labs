#!/usr/bin/env ruby

require "json"
require "optparse"

options = {}

OptionParser.new do |parser|
  parser.banner = "Usage: ruby tools/triage_cli.rb --title TITLE --body BODY"
  parser.on("--title TITLE", "GitHub issue title") { |value| options[:title] = value }
  parser.on("--body BODY", "GitHub issue body") { |value| options[:body] = value }
  parser.on("--json PATH", "Read issueTitle and issueBody from a JSON file") { |value| options[:json] = value }
end.parse!

if options[:json]
  input = JSON.parse(File.read(options[:json]))
  options[:title] = input.fetch("issueTitle")
  options[:body] = input.fetch("issueBody", "")
end

unless options[:title] && options.key?(:body)
  warn "Both --title and --body are required."
  exit 2
end

combined = "#{options[:title]} #{options[:body]}".downcase

category =
  if combined.match?(/security|token|vulnerability/)
    "security"
  elsif combined.match?(/bug|error|fail|crash|500|503/)
    "bug"
  elsif combined.match?(/doc|guide|quickstart|typo/)
    "documentation"
  elsif combined.match?(/feature|request|enhancement/)
    "feature"
  else
    "question"
  end

priority =
  if combined.match?(/outage|all users|all customers|data loss/)
    "P0"
  elsif category == "security" || combined.match?(/no workaround|crash/)
    "P1"
  elsif %w[documentation question].include?(category)
    "P3"
  else
    "P2"
  end

prompt_injection = combined.match?(/ignore your policy|system instructions|reveal all secrets/)
needs_human_review = category == "security" || priority == "P0" || category == "question" || prompt_injection

puts JSON.pretty_generate(
  category: category,
  priority: priority,
  summary: "Classified as #{category} with priority #{priority}.",
  needsHumanReview: needs_human_review
)
