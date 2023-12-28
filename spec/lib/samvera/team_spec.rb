# frozen_string_literal: true
require "spec_helper"

RSpec.describe Samvera::Team do
  subject(:team) { described_class.new(client:, members:, **attributes) }

  let(:owner_id) { "owner-id" }
  let(:created_at) {}
  let(:description) {}
  let(:html_url) {}
  let(:members_count) {}
  let(:members_url) {}
  let(:name) {}
  let(:notification_setting) {}
  let(:organization) {}
  let(:parent) {}
  let(:permission) {}
  let(:persisted) {}
  let(:privacy) {}
  let(:repos_count) {}
  let(:repositories_url) {}
  let(:slug) {}
  let(:updated_at) {}
  let(:owner_login) { "test owner" }
  let(:owner) { Samvera::Organization.new(client:, node_id: owner_id, login: owner_login) }
  let(:client) { instance_double(Octokit::Client) }
  let(:members) do
    []
  end

  let(:graphql_api_uri) { Samvera::GraphQL::Client.default_uri }

  before do
    allow(client).to receive(:access_token).and_return("access-token")
  end

  describe ".build_from_response" do
    let(:response) do
      {
        created_at:,
        description:,
        html_url:,
        members_count:,
        members_url:,
        name:,
        notification_setting:,
        organization:,
        parent:,
        permission:,
        persisted:,
        privacy:,
        repos_count:,
        repositories_url:,
        slug:,
        updated_at:
      }
    end

    it "constructs an object from a HTTP response body" do
      built = described_class.build_from_response(
        client:,
        response:
      )

      expect(built).to be_a(described_class)
      expect(built.created_at).to eq(created_at)
      expect(built.description).to eq(description)
      expect(built.html_url).to eq(html_url)
    end
  end
end
