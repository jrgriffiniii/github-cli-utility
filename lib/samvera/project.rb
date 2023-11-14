# frozen_string_literal: true

require_relative "repository/node"

module Samvera
  class Project < Repository::Node
    attr_accessor :body
    attr_accessor :closed_at
    attr_accessor :created_at
    attr_accessor :database_id
    attr_accessor :items
    attr_accessor :resource_path
    attr_accessor :short_description
    attr_accessor :title
    attr_accessor :updated_at

    def self.find_children_by(api_token:, login:, **attrs)
      graphql_client = build_graphql_client(api_token:)
      graphql_nodes = graphql_client.find_projects_by_org(login:)

      selected = graphql_nodes.select do |graphql_node|
        matches = false
        attrs.each_pair do |key, value|
          graphql_key = key.to_s
          matches = true if !matches && graphql_node.key?(graphql_key) && graphql_node[graphql_key] == value
        end
        matches
      end

      selected
    end

    def self.where(repository:, **attrs)
      selected = find_children_by(api_token: repository.client.access_token, login: repository.owner.login, **attrs)

      selected.map do |graphql_node|
        attrs = {}
        attrs["closed_at"] = graphql_node["closedAt"]
        attrs["created_at"] = graphql_node["createdAt"]
        attrs["database_id"] = graphql_node["databaseId"]

        # For consistency with the other models
        attrs["node_id"] = graphql_node["id"]
        attrs["id"] = graphql_node["number"]

        attrs["resource_path"] = graphql_node["resourcePath"]
        attrs["short_description"] = graphql_node["shortDescription"]
        attrs["title"] = graphql_node["title"]
        attrs["updated_at"] = graphql_node["updatedAt"]

        items = graphql_node["items"]
        item_nodes = items["nodes"]
        attrs["items"] = item_nodes

        new(repository:, **attrs)
      end
    end

    def create
      return self if persisted?

      graphql_results = graphql_client.create_project(owner_id: owner.node_id, repository_id: repository.node_id, title:)
      self.node_id = graphql_results["id"]
      @persisted = true
      reload
    end

    def add_item(item_node_id:)
      graphql_client.add_project_item(project_id: self.node_id, item_id: item_node_id)
    end

    # Find the GraphQL item node ID for any given issue or pull request GraphQL
    #   node ID
    # @param [String] the GraphQL node ID
    # @return [String]
    def find_item_id_for(node_id:)
      selected = items.select { |item| item["content"]["id"] == node_id }
      return if selected.empty?

      item = selected.first
      item["id"]
    end

    # Remove the association between a pull request or issue with a project
    # @param [String] the GraphQL node ID
    def remove_pull_request(node_id:)
      item_node_id = find_item_id_for(node_id:)
      graphql_client.delete_project_item(project_id: self.node_id, item_id: item_node_id)
    end

    def delete
      graphql_results = graphql_client.delete_project(project_id: self.node_id)
      @persisted = false
      self
    end
  end
end
