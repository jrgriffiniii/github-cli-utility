# frozen_string_literal: true

module Samvera
  module REST
    class Node
      attr_accessor :id,
                    :name,
                    :node_id,
                    :persisted,
                    :url

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
