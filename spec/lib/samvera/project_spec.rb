# frozen_string_literal: true
require "spec_helper"

RSpec.describe Samvera::Project do
  subject(:project) { described_class.new(repository:, **attributes) }

  #let(:repository) { FactoryBot.create(:repository) }
  let(:client) { instance_double(Octokit::Client) }
  let(:owner_id) { "owner-id" }
  let(:owner_login) { "test owner" }
  let(:owner) { Samvera::Organization.new(client:, node_id: owner_id, login: owner_login) }
  let(:repository_id) { "repository-id" }
  let(:repository) { Samvera::Repository.new(owner:, node_id: repository_id) }
  let(:id) { "test-id" }
  let(:node_id) { "test-node-id" }
  let(:title) { "test title" }
  let(:attributes) do
    {
      id:,
      node_id:,
      title:
    }
  end

  before do
    allow(client).to receive(:access_token).and_return("access-token")

    stub_request(:post, graphql_api_uri).with(
      body: graphql_query_json,
      headers: graphql_query_headers
    ).to_return(status: 200, body: graphql_response)
  end

  describe "#create" do
    let(:attributes) do
      {
        title:
      }
    end

    let(:mutation) { Samvera::GraphQL::Client.create_project_mutation }
    let(:variables) do
      {
        ownerId: owner_id,
        title:,
        repositoryId: repository_id
      }
    end
    let(:graphql_results) do
      {
        data: {
          createProjectV2: {
            projectV2: {
              id: node_id
            }
          }
        }
      }
    end
    let(:graphql_response) do
      JSON.generate(graphql_results)
    end
    let(:graphql_query) do
      {
        query: mutation,
        variables:
      }
    end
    let(:graphql_query_json) { JSON.generate(graphql_query) }
    let(:access_token) { "access-token" }
    let(:graphql_query_headers) do
      {
        "Accept" => "application/json",
        "Authorization" => "bearer #{access_token}",
        "Content-Type" => "application/json"
      }
    end
    let(:graphql_api_uri) { Samvera::GraphQL::Client.default_uri }

    before do
      stub_graphql_find_projects_by_org(login: owner_login, access_token:)
      project.create
    end

    it "transmits a GraphQL request to the GitHub API" do
      expect(a_request(:post, graphql_api_uri).with(body: graphql_query_json, headers: graphql_query_headers)).to have_been_made.once
    end

    it "updates the state of the project" do
      expect(project.persisted?).to be true
      expect(project.node_id).to eq(node_id)
    end

  end

  describe "#delete" do
    let(:mutation) { Samvera::GraphQL::Client.delete_project_mutation }
    let(:variables) do
      {
        projectId: node_id
      }
    end
    let(:graphql_results) do
      {
        data: {
          deleteProjectV2: {
            projectV2: {
              id: node_id
            }
          }
        }
      }
    end
    let(:graphql_response) do
      JSON.generate(graphql_results)
    end
    let(:graphql_query) do
      {
        query: mutation,
        variables:
      }
    end
    let(:graphql_query_json) { JSON.generate(graphql_query) }
    let(:access_token) { "access-token" }
    let(:graphql_query_headers) do
      {
        "Accept" => "application/json",
        "Authorization" => "bearer #{access_token}",
        "Content-Type" => "application/json"
      }
    end
    let(:graphql_api_uri) { Samvera::GraphQL::Client.default_uri }

    before do
      project.delete
    end

    it "transmits a GraphQL request to the GitHub API" do
      expect(a_request(:post, graphql_api_uri).with(body: graphql_query_json, headers: graphql_query_headers)).to have_been_made.once
    end

    it "updates the state of the project" do
      expect(project.persisted?).to be false
    end

  end
end
