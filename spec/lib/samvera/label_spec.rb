# frozen_string_literal: true
require "spec_helper"

RSpec.describe Samvera::Label do
  subject(:label) { described_class.new(repository:, **attributes) }

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
  let(:url) { "http://localhost/test-label" }
  let(:color) { "#ffffff" }
  let(:default) { false }
  let(:description) { "test description" }
  let(:attributes) do
    {
      id:,
      name:,
      node_id:,
      persisted:,
      url:,
      color:,
      default:,
      description:
    }
  end
  let(:client_response) { double }

  before do
    allow(client_response).to receive(:to_hash).and_return(attributes)
    allow(client).to receive(:add_label)
    allow(client).to receive(:label).and_return(client_response)

  end

  describe "#create" do
    before do
      label.create
    end

    it "transmits a HTTP request to the GitHub API" do
    end

    it "updates the state of the label" do
      expect(label.persisted?).to be true
      expect(label.node_id).to eq(node_id)
    end

  end

end
