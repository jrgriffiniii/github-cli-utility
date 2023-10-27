# frozen_string_literal: true

def stub_graphql_find_projects_by_org(login:, access_token:, nodes: [])
  graphql_results = {
    data: {
      organization: {
        projectsV2: {
          nodes:
        }
      }
    }
  }
  graphql_response = JSON.generate(graphql_results)

  query = Samvera::GraphQL::Client.find_projects_by_org_query
  variables = {
    login:
  }
  graphql_query = {
    query:,
    variables:
  }
  graphql_query_json = JSON.generate(graphql_query)
  graphql_query_headers = {
    "Accept" => "application/json",
    "Authorization" => "bearer #{access_token}",
    "Content-Type" => "application/json"
  }

  graphql_api_uri = Samvera::GraphQL::Client.default_uri

  stub_request(:post, graphql_api_uri).with(
    body: graphql_query_json,
    headers: graphql_query_headers
  ).to_return(status: 200, body: graphql_response)
end
