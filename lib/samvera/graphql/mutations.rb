# frozen_string_literal: true

module Samvera
  module GraphQL
    class Mutations
      FIRST = 100

      # GraphQL mutations

      # https://docs.github.com/en/graphql/reference/mutations#createprojectv2
      # https://docs.github.com/en/graphql/reference/input-objects#createprojectv2input
      def self.create_project
        <<-GRAPHQL
          mutation($ownerId: ID!, $title: String!, $repositoryId: ID!) {
            createProjectV2(input: { ownerId: $ownerId, title: $title, repositoryId: $repositoryId }) {
              projectV2 {
                id
                title
              }
            }
          }
        GRAPHQL
      end

      # https://docs.github.com/en/graphql/reference/mutations#deleteprojectv2
      # https://docs.github.com/en/graphql/reference/input-objects#deleteprojectv2input
      def self.delete_project
        <<-GRAPHQL
          mutation($projectId: ID!) {
            deleteProjectV2(input: { projectId: $projectId }) {
              projectV2 {
                id
              }
            }
          }
        GRAPHQL
      end

      # https://docs.github.com/en/graphql/reference/mutations#addprojectv2itembyid
      # https://docs.github.com/en/graphql/reference/input-objects#addprojectv2itembyidinput
      def self.add_project_item_by_id
        <<-GRAPHQL
          mutation($projectId: ID!, $contentId: ID!) {
            addProjectV2ItemById(input: { projectId: $projectId contentId: $contentId }) {
              item {
                id
              }
            }
          }
        GRAPHQL
      end

      # https://docs.github.com/en/graphql/reference/mutations#deleteprojectv2item
      # https://docs.github.com/en/graphql/reference/input-objects#deleteprojectv2iteminput
      def self.delete_project_item
        <<-GRAPHQL
          mutation($itemId: ID!, $projectId: ID!) {
            deleteProjectV2Item(input: { itemId: $itemId projectId: $projectId }) {
              deletedItemId
            }
          }
        GRAPHQL
      end

      # https://docs.github.com/en/graphql/reference/mutations#addassigneestoassignable
      def self.add_assignees
        <<-GRAPHQL
          mutation($assignableId: ID!, $assigneeIds: [ID!]!) {
            addAssigneesToAssignable(input: { assignableId: $assignableId, assigneeIds: $assigneeIds }) {
              assignable {
                assignees(first: #{FIRST}) {
                  nodes {
                    id
                  }
                }
              }
            }
          }
        GRAPHQL
      end

      # https://docs.github.com/en/graphql/reference/mutations#removeassigneesfromassignable
      def self.remove_assignees
        <<-GRAPHQL
          mutation($assignableId: ID!, $assigneeIds: [ID!]!) {
            removeAssigneesFromAssignable(input: { assignableId: $assignableId, assigneeIds: $assigneeIds }) {
              assignable {
                assignees(first: #{FIRST}) {
                  nodes {
                    id
                  }
                }
              }
            }
          }
        GRAPHQL
      end
    end
  end
end
