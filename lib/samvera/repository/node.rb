# frozen_string_literal: true

require_relative "../repository"
require_relative "../graphql/node"

module Samvera
  class Repository::Node < GraphQL::Node
    attr_reader :repository

    def self.build_from_json(repository:, json:)
      attrs = json.to_hash
      # These were persisted within the GitHub API
      attrs[:persisted] = true

      new(repository:, **attrs)
    end

    def self.find_by(**options)
      options[:parent] = options[:repository]
      persisted = where(**options)
      persisted.first
    end

    def self.find_or_create_by(repository:, **attrs)
      persisted = find_by(repository:, **attrs)
      return persisted unless persisted.nil?

      built = new(repository:, **attrs)
      built.create
    end

    def initialize(repository:, **attributes)
      @repository = repository

      attributes.each do |key, value|
        signature = "#{key}="
        self.public_send(signature, value)
      end

      @persisted ||= false
    end

    def persisted?
      @persisted
    end

    # `delegate` triggers strange behavior within Thor::CLI Classes
    def owner
      repository.owner
    end

    # `delegate` triggers strange behavior within Thor::CLI Classes
    def client
      owner.client
    end

    def reload
      self.class.find_by(repository:, name:)
    end
  end
end
