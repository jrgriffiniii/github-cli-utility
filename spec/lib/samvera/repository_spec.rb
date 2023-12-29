# frozen_string_literal: true
require "spec_helper"

RSpec.describe Samvera::Repository do
  subject(:repository) { described_class.new(owner:, **attributes) }

  let(:client) { instance_double(Octokit::Client) }
  let(:owner_id) { "owner-id" }
  let(:owner_login) { "test owner" }
  let(:owner) { Samvera::Organization.new(client:, node_id: owner_id, login: owner_login) }
  let(:id) { "test-id" }
  let(:node_id) { "test-node-id" }
  let(:name) { "test repository" }
  let(:attributes) do
    {
      id:,
      node_id:,
      name:
    }
  end

  before do
    allow(client).to receive(:access_token).and_return("access-token")
  end

  describe "#find_pull_request_by" do
    let(:number) { 1 }
    let(:title) { "test pull request" }
    let(:pull_request_response) do
      [
        {
          title:,
          number:
        }
      ]
    end

    before do
      allow(client).to receive(:pull_requests).and_return(pull_request_response)
    end

    it "transmits a GraphQL request to the GitHub API" do
      pull_request = repository.find_pull_request_by(number:)
      expect(pull_request).to be_a(Samvera::PullRequest)
      expect(pull_request.number).to eq(number)
      expect(pull_request.title).to eq(title)
    end
  end

  describe "#issues" do
    let(:list_issue) do
      {
        labels: [],
        reactions: [],
        user: {}
      }
    end
    let(:list_issues) do
      [
        list_issue
      ]
    end

    before do
      allow(client).to receive(:list_issues).and_return(list_issues)
    end

    it "retrieves all of the GitHub Issues for a given repository" do
      issues = repository.issues
      expect(issues).to be_an(Array)
      expect(issues).not_to be_empty
      issue = issues.last

      expect(issue).to be_a(Samvera::Issue)
    end
  end
end
