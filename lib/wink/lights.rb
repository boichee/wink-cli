
require_relative './api'
require_relative './device'

class Light < Device
  # We'll keep track of all lights on a static property
  @@lights = Array.new
  @@user = nil

  # all: Provides a public getter for the @@lights static prop
  def self.all
    @@lights
  end

  # create_from_api: Allows you to create a new switch directly from the JSON the API returns
  def self.create_from_api(h, user = nil)
    unless h.has_key? 'light_bulb_id' # If the passed hash doesn't have this key, it's a light or some other kind of device
      return nil
    end

    @@user = user
    return self.new h['uuid'], h['light_bulb_id'], h['name'], h['last_reading']
  end

  def print
    puts "------------------ LIGHT -------------------"
    puts self
    puts "Name: #{@name}"
    puts "ID: #{@id}"
    puts "UUID: #{@uuid}"
    puts "Powered: #{@device_state.powered}"
    puts "--------------------------------------------"
    puts
  end

  private
  def update
    resp = @@user.request(
      "/light_bulbs/#{@id}/desired_state",
      method: Wink::HttpMethods.Put,
      body: @device_state.prepare_for_api,
      headers: { content_type: 'application/json' }
    )

    if resp.code != 200
      p resp.body
      p resp
      raise RuntimeError, "An error occurred while attempting to contact the Wink API", caller
    end

    puts 'Success!'
  end

end
