# frozen_string_literal: true

module Samvera
  module REST
    class Node
      attr_accessor :id,
                    :name,
                    :node_id,
                    :persisted,
                    :url

      #def self.find_children_by(parent:, client_method:, client_method_args:, **attrs)
      def self.find_children_by(client:, client_method:, client_method_args:, **attrs)
        # graphql_client = build_graphql_client(api_token: parent.access_token)
        # graphql_nodes = graphql_client.send(client_method, **client_method_args)
        #rest_client = build_rest_client(api_token: parent.access_token)
        responses = client.send(client_method, **client_method_args)

        #selected = graphql_nodes.select do |graphql_node|
        selected = responses.select do |response|
          matches = false
          response.each_pair do |key, value|
            rest_key = key.to_s
            matches = true if !matches && response.key?(rest_key) && response[rest_key] == value
          end
          matches
        end

        selected
      end

      def self.where(client:, **attrs)
        selected = find_children_by(client:, client_method:, client_method_args:, **attrs)
        selected.map do |json|
          build(client:, json:)
        end
      end


      def self.build(client:, json:)
        attrs = json.to_hash
        # These were persisted within the GitHub API
        attrs[:persisted] = true

        new(client:, **attrs)
      end

      def initialize(client:, **attributes)
        @client = client

        attributes.each do |key, value|
          signature = "#{key}="
          self.public_send(signature, value)
        end
      end
    end
  end
end
