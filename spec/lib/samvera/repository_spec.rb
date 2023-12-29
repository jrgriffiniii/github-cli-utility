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

  let(:graphql_api_uri) { Samvera::GraphQL::Client.default_uri }
  let(:graphql_query_json) { JSON.generate(graphql_query) }
  let(:access_token) { "access-token" }
  let(:graphql_query_headers) do
    {
      "Accept" => "application/json",
      "Authorization" => "bearer #{access_token}",
      "Content-Type" => "application/json"
    }
  end
  let(:graphql_query) do
    {}
  end
  let(:graphql_results) do
    {
      data: {}
    }
  end
  let(:graphql_response) do
    JSON.generate(graphql_results)
  end



  before do
    allow(client).to receive(:access_token).and_return("access-token")

    #stub_request(:post, graphql_api_uri).with(
    #  body: graphql_query_json,
    #  headers: graphql_query_headers
    #).to_return(status: 200, body: graphql_response)
  end

  describe "#pull_requests" do
    let(:attributes) do
      {
        name:
      }
    end

    let(:mutation) { Samvera::GraphQL::Mutations.create_project }
    let(:variables) do
      {
        ownerId: owner_id,
        name:
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
    let(:number) { 1 }
    let(:title) { "test pull request" }
    let(:pull_request_response) do
      [
        {
          title:
        }

      ]
    end

    before do
      # stub_graphql_find_projects_by_org(login: owner_login, access_token:)
      # project.create
      allow(client).to receive(:pull_requests).and_return(pull_request_response)

    end

    it "transmits a GraphQL request to the GitHub API" do
      #expect(a_request(:post, graphql_api_uri).with(body: graphql_query_json, headers: graphql_query_headers)).to have_been_made.once
      resource = repository.find_pull_request_by(number:)
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
