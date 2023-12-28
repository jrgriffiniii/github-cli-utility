# frozen_string_literal: true
require "spec_helper"

RSpec.describe Samvera::Owner do
  subject(:owner) do
    described_class.new(client:, node_id: owner_id, login: owner_login)
  end

  let(:node_id) { "test-node-id" }
  let(:owner_id) { "owner-id" }
  let(:owner_login) { "test owner" }
  let(:client) { instance_double(Octokit::Client) }

  let(:graphql_api_uri) { Samvera::GraphQL::Client.default_uri }

  before do
    allow(client).to receive(:access_token).and_return("access-token")
  end

  describe ".build_from_response" do
    let(:id) {}
    let(:name) {}
    let(:node_id) {}
    let(:persisted) {}
    let(:url) {}
    let(:avatar_url) {}
    let(:description) {}
    let(:events_url) {}
    let(:hooks_url) {}
    let(:issues_url) {}
    let(:login) {}
    let(:repos_url) {}
    let(:response) do
      {
        id:,
        name:,
        node_id:,
        persisted:,
        url:,
        avatar_url:,
        description:,
        events_url:,
        hooks_url:,
        issues_url:,
        login:,
        repos_url:
      }
    end
    let(:responses) do
      [
        response
      ]
    end

    it "constructs an object from a HTTP response body" do
      objects = described_class.build_from_responses(
        client:,
        responses:
      )

      expect(objects).to be_an(Array)
      expect(objects).not_to be_empty
      built = objects.last
      expect(built).to be_a(described_class)
      expect(built.url).to eq(url)
      expect(built.description).to eq(description)
    end
  end

  describe "#find_repository_by" do
    let(:repository_name) { "repository" }
    let(:organization_repositories) do
      [
        {
          name: repository_name
        }
      ]
    end

    before do
      allow(client).to receive(:organization_repositories).and_return(organization_repositories)
    end

    it "finds the Repository object using selected attributes" do
      repository = owner.find_repository_by(name: repository_name)
      expect(repository).to be_a(Samvera::Repository)
      expect(repository.name).to eq(repository_name)
    end
  end
end
