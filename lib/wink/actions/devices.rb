# devices.rb
# Wink::Actions::Devices

require_relative '../api'

module Wink
  module Actions
    class Devices < API
      attr_accessor @all, @lights, @switches

      class << self
        def all
          api = self.new API::Request.new('/users/me/wink_devices')
          api.go
          api.

        end
      end


      # I'm thinking that we may not actually need this
      def initialize
        super API::Request.new('/users/me/wink_devices')
      end

      def all
        @all = @response.data
        @lights = @all.select { |x| x.has_key? 'light_bulb_id' }
        @switches = @all.select { |x| x.has_key? 'binary_switch_id' }

        self
      end

      def get(nameOrId)
        @id = @name = nil

        if nameOrId != nil
          if nameOrId.to_i === 0
            @name = nameOrId
          else
            @id = nameOrId
          end
        end
      end



    end

  end

end
