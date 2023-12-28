# frozen_string_literal: true

require_relative "repository"
require_relative "rest/node"

module Samvera
  class Owner < REST::Node
    attr_reader :client
    attr_accessor :avatar_url,
                  :description,
                  :events_url,
                  :hooks_url,
                  :issues_url,
                  :login,
                  :repos_url

    def self.build_from_responses(client:, responses:)
      responses.map do |org_json|
        new(client:, **org_json)
      end
    end

    def repositories(**options)
      response = @client.organization_repositories(login, **options)
      Repository.build_from_hash(owner: self, values: response)
    end

    def find_repository_by(name:, **options)
      all = repositories(**options)
      filtered = all.select { |repo| repo.name == name }
      filtered.first
    end

    def find_repository_by!(name:, **options)
      repository = find_repository_by(name:, **options)
      return repository unless repository.nil?

      error_message = "Failed to resolve the Repository: #{name}"
      raise(StandardError, error_message)
    end
  end
end
