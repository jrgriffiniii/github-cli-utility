# frozen_string_literal: true

module Samvera
  module GraphQL
    class Queries
      FIRST = 100

      # GraphQL queries

      # https://docs.github.com/en/graphql/reference/queries#organization
      # https://docs.github.com/en/graphql/reference/objects#organization
      # https://docs.github.com/en/graphql/reference/objects#projectv2
      def self.find_projects_by_org
        <<-GRAPHQL
          query($login: String!) {
            organization(login: $login) {
              projectsV2(first: #{FIRST}) {
                nodes {
                  closed
                  closedAt
                  createdAt
                  databaseId
                  id
                  number
                  public
                  readme
                  resourcePath
                  shortDescription
                  template
                  title
                  updatedAt
                  url
                  items(first: #{FIRST}) {
                    nodes {
                      id
                      type
                      content {
                        ... on PullRequest {
                          id
                        }
                      }
                    }
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
