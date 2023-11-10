# frozen_string_literal: true
require "spec_helper"

RSpec.describe Samvera::RubyGems::Client do
  subject(:client) { described_class.new(api_key:, mfa:, uri:, otp:) }

  let(:api_key) { "api_key" }
  let(:mfa) { false }
  let(:uri) { nil }
  let(:otp) { nil }

  let(:response_body_json) do
    JSON.generate(response_body)
  end

  describe "#gems" do
    let(:response_body) do
      [
        {
          "name": "rails",
          "downloads": 7528417,
          "version": "3.2.1",
          "version_downloads": 47602,
          "authors": "David Heinemeier Hansson",
          "info": "Ruby on Rails is a full-stack web framework optimized for programmer
                  happiness and sustainable productivity. It encourages beautiful code
                  by favoring convention over configuration.",
          "project_uri": "http://rubygems.org/gems/rails",
          "gem_uri": "http://rubygems.org/gems/rails-3.2.1.gem",
          "homepage_uri": "http://www.rubyonrails.org",
          "wiki_uri": "http://wiki.rubyonrails.org",
          "documentation_uri": "http://api.rubyonrails.org",
          "mailing_list_uri": "http://groups.google.com/group/rubyonrails-talk",
          "source_code_uri": "http://github.com/rails/rails",
          "bug_tracker_uri": "http://github.com/rails/rails/issues",
          "dependencies": {
          }
        }
      ]
    end
    let(:gems) { client.gems }

    before do
      stub_request(
        :get,
        "https://rubygems.org/api/v1/gems.json"
      ).to_return(
        status: 200,
        headers: {
          "content-type": "application/json"
        },
        body: response_body_json
      )
    end

    it "retrieves all Gems owned by a given user" do
      expect(gems).not_to be_empty
      first_gem = gems.first
      expect(first_gem).to be_a(Samvera::RubyGems::Gem)
      expect(first_gem.name).to eq("rails")
    end
  end

  describe "#find_gem_by" do
    let(:response_body) do
      {
        "name": "rails",
        "downloads": 7528417,
        "version": "3.2.1",
        "version_downloads": 47602,
        "authors": "David Heinemeier Hansson",
        "info": "Ruby on Rails is a full-stack web framework optimized for programmer
                happiness and sustainable productivity. It encourages beautiful code
                by favoring convention over configuration.",
        "project_uri": "http://rubygems.org/gems/rails",
        "gem_uri": "http://rubygems.org/gems/rails-3.2.1.gem",
        "homepage_uri": "http://www.rubyonrails.org",
        "wiki_uri": "http://wiki.rubyonrails.org",
        "documentation_uri": "http://api.rubyonrails.org",
        "mailing_list_uri": "http://groups.google.com/group/rubyonrails-talk",
        "source_code_uri": "http://github.com/rails/rails",
        "bug_tracker_uri": "http://github.com/rails/rails/issues",
        "dependencies": {
        }
      }
    end
    let(:name) { "rails" }
    let(:found) do
      client.find_gem_by(name:)
    end

    before do
      stub_request(
        :get,
        "https://rubygems.org/api/v1/gems/rails.json"
      ).to_return(
        status: 200,
        headers: {
          "Content-Type": "application/json"
        },
        body: response_body_json
      )
    end

    it "retrieves a Gem given the name for the Gem" do
      expect(found).to be_a(Samvera::RubyGems::Gem)
      expect(found.name).to eq("rails")
    end
  end


end
