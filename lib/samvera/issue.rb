# frozen_string_literal: true

require_relative "repository/node"

module Samvera
  class Issue < Repository::Node
    attr_accessor :active_lock_reason,
                  :assignee,
                  :assignees,
                  :author_association,
                  :body,
                  :closed_at,
                  :comments,
                  :comments_url,
                  :created_at,
                  :draft,
                  :events_url,
                  :html_url,
                  :labels_url,
                  :locked,
                  :milestone,
                  :number,
                  :performed_via_github_app,
                  :pull_request,
                  :repository_url,
                  :state,
                  :state_reason,
                  :timeline_url,
                  :title,
                  :updated_at

    def self.build_from_hash(repository:, response:)
      response.map do |attrs|
        # Remove one-to-many associations
        attrs.delete(:labels)
        attrs.delete(:reactions)
        attrs.delete(:user)

        new(repository:, **attrs)
      end
    end

    def self.find_children(parent:, **options)
      response = parent.client.list_issues(parent.path, **options)

      build_from_hash(repository: parent, response:)
    end

    # This relies upon the REST API
    def self.where(parent:, **attrs)
      # REST::Node.where(parent:, **attrs)

      children = find_children(parent:)
      filtered = children.select do |child|
        matches = attrs.map do |k, v|
          child.public_send(k) == v
        end
        matches.reduce(:|)
      end
      filtered
    end

    def initialize(repository:, **attributes)
      @repository = repository
      @owner = @repository.owner

      attributes.each do |key, value|
        signature = "#{key}="
        self.public_send(signature, value)
      end
    end

    # https://docs.github.com/en/graphql/reference/mutations#addassigneestoassignable
    # https://docs.github.com/en/graphql/reference/input-objects#addassigneestoassignableinput
    def add_assignees(assignees:)
      assignee_ids = assignees.map { |a| a.node_id }
      graphql_client.add_assignees(node_id: self.node_id, assignee_ids:)
    end

    # https://docs.github.com/en/graphql/reference/mutations#removeassigneesfromassignable
    # https://docs.github.com/en/graphql/reference/input-objects#removeassigneesfromassignableinput
    def remove_assignees(assignees:)
      assignee_ids = assignees.map { |a| a.node_id }
      graphql_client.remove_assignees(node_id: self.node_id, assignee_ids:)
    end
  end
end
