# frozen_string_literal: true

require "spec_helper"

describe Samvera::GraphQL::Client do
  subject(:client) { described_class.new(api_token:, context:, schema_cached:, uri:, schema_uri:) }

  let(:api_token) { "test-api-token" }
  let(:context) do
    {}
  end
  let(:schema_cached) { nil }
  let(:uri) { nil }
  let(:schema_uri) { nil }

  describe ".default_uri" do
    it "accesses the URL for the GitHub API" do
      expect(described_class.default_uri).to eq("https://api.github.com/graphql")
    end
  end

  describe ".default_schema_uri" do
    it "accesses the URL for the GitHub GraphQL schema URL" do
      expect(described_class.default_schema_uri).to eq("https://docs.github.com/public/schema.docs.graphql")
    end
  end

  context "when constructed with an API token" do
    let(:owner_id) { "test-user-id" }
    let(:title) { "test title" }
    let(:repository_id) { "test repository ID" }

    before do
      stub_request(:post, "https://api.github.com/graphql").to_return(
        status: 200,
        headers: response_headers,
        body: response_body
      )
    end

    context "with an existing project" do
      let(:login) { "test-user" }
      let(:id) { "test-id" }
      let(:name) { "test-name" }
      let(:node_id) { "test-node-id" }
      let(:url) { "https://localhost.localdomain" }
      let(:items) do
        []
      end
      let(:project_json) do
        {
          id:,
          name:,
          node_id:,
          url:,

          body: nil,
          closed_at: nil,
          created_at: nil,
          database_id: nil,
          items:,
          resource_path: nil,
          short_description: nil,
          title:,
          updated_at: nil
        }
      end
      let(:response_headers) do
        [
          "Content-Type": "application/json"
        ]
      end
      let(:response_body) do
        JSON.generate(response_body_json)
      end

      describe "#find_projects_by_org" do
        let(:response_body_json) do
          {
            data: {
            organization: {
              projectsV2: {
                nodes: [
                  project_json

                ]
              }
            }
            }
          }
        end

        it "finds all GitHub projects given an organization" do
          projects = client.find_projects_by_org(login:)
        end
      end

      describe "#add_project_item" do
        let(:response_body_json) do
          {
          }
        end
        it "adds an Issue or Pull Request to a given project" do
          projects = client.add_project_item(project_id:, item_id:)
        end
      end

      describe "#delete_project_item" do
        let(:project_item) do
          {
            "content" => {
              "id" => item_id
            }
          }
        end
        let(:response_body_json) do
          {
            data: {
              deleteProjectV2Item: {
                item: project_item
              }
            }
          }
        end
        let(:item_id) { "test-item-id" }
        let(:project_id) { "test-project-id" }

        it "removes an Issue or Pull Request from a given project" do
          item = client.delete_project_item(item_id:, project_id:)
          expect(item).to eq(project_item)
        end
      end

      describe "#delete_project" do
        it "deletes any given project" do
          projects = client.delete_project(project_id:)
        end
      end

      describe "#add_assignees" do
        it "assigns an Issue or Pull Request to users" do
          projects = client.add_assignees(node_id:, assignee_ids:)
        end
      end

      describe "#remove_assignees" do
        it "remove users assigned to a given Issue or Pull Request" do
          projects = client.remove_assignees(node_id:, assignee_ids:)
        end
      end
    end

    describe "#create_project" do
      let(:project_json) do
        {
          id: nil,
          name: nil,
          node_id: nil,
          persisted: nil,
          url: nil,

          body: nil,
          closed_at: nil,
          created_at: nil,
          database_id: nil,
          items: [],
          resource_path: nil,
          short_description: nil,
          title: nil,
          updated_at: nil
        }
      end
      let(:response_headers) do
        [
          "Content-Type": "application/json"
        ]
      end
      let(:response_body_json) do
        {
          data: {
          createProjectV2: {
            projectV2: {
              nodes: [
                project_json

              ]
            }
          }
          }
        }
      end
      let(:response_body) do
        JSON.generate(response_body_json)
      end



      it "creates a new GitHub project" do
        response = client.create_project(owner_id:, title:, repository_id:)
        expect(response).to include("nodes")
        expect(response["nodes"]).to be_an(Array)
        expect(response["nodes"]).not_to be_empty
        first_node = response["nodes"].first
        expect(first_node).to include("title" => title)

      end
    end


  end

end
