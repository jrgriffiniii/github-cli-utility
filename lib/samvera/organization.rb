# frozen_string_literal: true

require_relative "owner"

module Samvera
  class Organization < Owner
    attr_accessor :members_url,
                  :public_members_url

    def self.find_by(login:)
      response = client.organizations(**options)
      response
    end

    def self.build_from_octokit(client:, **options)
      responses = client.organizations(**options)
      build_from_responses(client:, responses:)
    end
  end
end
