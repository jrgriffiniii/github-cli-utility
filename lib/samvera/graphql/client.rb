# frozen_string_literal: true

require "graphql/client"
require "graphql/client/http"

module Samvera
  module GraphQL
    class Client
      FIRST = 100

      def self.default_uri
        "https://api.github.com/graphql"
      end

      def self.default_schema_uri
        "https://docs.github.com/public/schema.docs.graphql"
      end

      def initialize(api_token:, context: {}, schema_cached: nil, uri: nil, schema_uri: nil)
        @api_token = api_token
        @context = {}
        @uri = uri || self.class.default_uri

        @schema_uri = schema_uri || self.class.default_schema_uri
        if schema_cached.nil?
          @schema_cached = File.exist?(schema_json_file)
        else
          @schema_cached = schema_cached
        end
      end

      # Support for GraphQL::Client might be unnecessary
      def client
        @client ||= ::GraphQL::Client.new(schema:, execute: http)
      end

      def http
        @http ||= ::GraphQL::Client::HTTP.new(@uri) do
          def headers(context)
            [
              "Authorization: bearer #{context['api_token']}"
            ]
          end
        end
      end

      def schema
        @schema ||= ::GraphQL::Client.load_schema(schema_json)
      end

      def queries
        Queries
      end

      def mutations
        Mutations
      end

      # Public methods for queries

      ## Projects

      def find_projects_by_org(login:)
        variables = {
          login:
        }
        results = execute_graphql_query(query: queries.find_projects_by_org, variables:)
        create_project_v2 = results["organization"]
        projects_v2 = create_project_v2["projectsV2"]
        nodes = projects_v2["nodes"]
        nodes
      end

      def create_project(owner_id:, title:, repository_id:)
        variables = {
          ownerId: owner_id,
          title:,
          repositoryId: repository_id
        }
        results = execute_graphql_query(query: mutations.create_project, variables:)
        create_project_v2 = results["createProjectV2"]
        project_v2 = create_project_v2["projectV2"]
        project_v2
      end

      def add_project_item(project_id:, item_id:)
        variables = {
          projectId: project_id,
          contentId: item_id
        }
        results = execute_graphql_query(query: mutations.add_project_item_by_id, variables:)
        add_project_v2_item_by_id = results["addProjectV2ItemById"]
        item = add_project_v2_item_by_id["item"]
        item
      end

      def delete_project_item(item_id:, project_id:)
        variables = {
          itemId: item_id,
          projectId: project_id
        }
        results = execute_graphql_query(query: mutations.delete_project_item, variables:)
        delete_project_v2_item = results["deleteProjectV2Item"]
        item = delete_project_v2_item["item"]
        item
      end

      def delete_project(project_id:)
        variables = {
          projectId: project_id
        }
        results = execute_graphql_query(query: mutations.delete_project, variables:)
        create_project_v2 = results["deleteProjectV2"]
        project_v2 = create_project_v2["projectV2"]
        project_v2
      end

      ## Issue/Pull Request Assignment
      def add_assignees(node_id:, assignee_ids:)
        variables = {
          assignableId: node_id,
          assigneeIds: assignee_ids
        }
        results = execute_graphql_query(query: mutations.add_assignees, variables:)
      end

      def remove_assignees(node_id:, assignee_ids:)
        variables = {
          assignableId: node_id,
          assigneeIds: assignee_ids
        }
        results = execute_graphql_query(query: mutations.remove_assignees, variables:)
      end

      private

      def build_graphql_request(query:, variables: nil, operation_name: nil)
        request = Net::HTTP::Post.new(@uri)
        request["Accept"] = "application/json"
        request["Content-Type"] = "application/json"
        request["Authorization"] = "bearer #{@api_token}"

        body = {}
        body["query"] = query
        body["variables"] = variables unless variables.nil?
        body["operationName"] = operation_name unless operation_name.nil?
        request.body = JSON.generate(body)

        request
      end

      def execute_graphql_query(query:, variables: nil)
        request = build_graphql_request(query:, variables:)
        response = http.connection.request(request)
        # Errors at the level of the HTTP
        raise(StandardError, "HTTP error encountered: #{response.body}") if response.code != "200"
        parsed = JSON.parse(response.body)
        # Errors within the GraphQL query (these return a 200 status code)
        if parsed.key?("errors")
          errors = parsed["errors"].map { |error| error["message"] }.join(" ")
          raise(StandardError, "GraphQL API error encountered: #{errors}")
        end

        response_data = parsed["data"]
        response_data
      end

      ## GraphQL Schema management
# GraphQL schema handling might not be necessary
      def build_schema_request
        request = Net::HTTP::Get.new(@uri)
        request["Accept"] = "application/json"
        request["Content-Type"] = "application/json"
        request["Authorization"] = "bearer #{@api_token}"
        request
      end

      def schema_response
        request = build_schema_request
        http.connection.request(request)
      end

      def schema_cached?
        @schema_cached
      end

      def schema_json_file
        File.join(__dir__, "schema.json")
      end

      def schema_cache
        File.read(schema_json_file)
      end

      def update_schema_cache(json:)
        fh = File.open(schema_json_file, "wb")
        fh.write(json)
        fh.close
        @schema_cached = true
        schema_json_file
      end

      def schema_json
        parsed = if schema_cached?
                   JSON.parse(schema_cache)
        else
          update_schema_cache(json: schema_response)
          JSON.parse(schema_response)
        end

        parsed
      end

    end
  end
end
