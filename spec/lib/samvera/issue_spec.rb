# frozen_string_literal: true
require "spec_helper"

RSpec.describe Samvera::Issue do
  subject(:issue) { described_class.new(repository:, **attributes) }

  let(:client) { instance_double(Octokit::Client) }
  let(:owner_id) { "owner-id" }
  let(:owner_login) { "test owner" }
  let(:owner) { Samvera::Organization.new(client:, node_id: owner_id, login: owner_login) }
  let(:repository_id) { "repository-id" }
  let(:repository) { Samvera::Repository.new(owner:, node_id: repository_id) }

  # attributes
  let(:id) { "test-id" }
  let(:name) { "test name" }
  let(:node_id) { "test-node-id" }
  let(:persisted) { false }
  let(:url) { "http://localhost/test-issue" }

  let(:active_lock_reason) { "test" }
  let(:assignee) { "test" }
  let(:assignees) { "test" }
  let(:author_association) { "test" }
  let(:body) { "test" }
  let(:closed_at) { "test" }
  let(:comments) { "test" }
  let(:comments_url) { "test" }
  let(:created_at) { "test" }
  let(:draft) { "test" }
  let(:events_url) { "test" }
  let(:html_url) { "test" }
  let(:labels_url) { "test" }
  let(:locked) { "test" }
  let(:milestone) { "test" }
  let(:number) { "test" }
  let(:performed_via_github_app) { "test" }
  let(:pull_request) { "test" }
  let(:repository_url) { "test" }
  let(:state) { "test" }
  let(:state_reason) { "test" }
  let(:timeline_url) { "test" }
  let(:title) { "test" }
  let(:updated_at) { "test" }

  let(:attributes) do
    {
      id:,
      name:,
      node_id:,
      persisted:,
      url:,

      active_lock_reason:,
      assignee:,
      assignees:,
      author_association:,
      body:,
      closed_at:,
      comments:,
      comments_url:,
      created_at:,
      draft:,
      events_url:,
      html_url:,
      labels_url:,
      locked:,
      milestone:,
      number:,
      performed_via_github_app:,
      pull_request:,
      repository_url:,
      state:,
      state_reason:,
      timeline_url:,
      title:,
      updated_at:
    }
  end
  let(:client_response) { double }

  before do
    allow(client_response).to receive(:to_hash).and_return(attributes)

  end

  describe ".find_children_by" do
  end

  describe ".find_or_create_by" do
    let(:issue) { described_class.find_or_create_by(repository:, number:) }

    let(:list_issues_response) { double }
    let(:persisted_attributes) do
      attributes.merge({
        persisted: true
      })
    end
    let(:list_issues_response_body) do
      [
        persisted_attributes
      ]
    end

    before do
      allow(list_issues_response).to receive(:to_hash).and_return(list_issues_response_body)
      allow(client).to receive(:list_issues).and_return(list_issues_response)
    end

    context "when the issue exists" do
      it "finds the persisted issue" do
        expect(issue.persisted?).to be true
        expect(issue.node_id).to eq(node_id)
      end
    end
  end

end
