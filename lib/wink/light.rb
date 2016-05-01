
require_relative './api'

class Light
  # We'll keep track of all lights on a static property
  @@lights = Array.new
  @@user = nil

  # all: Provides a public getter for the @@lights static prop
  def self.all
    @@lights
  end

  def self.get_from_api(name)
    @@user = User.new(1, 2)
    data = @@user.all_devices
    data.select! {|x| x['name'] === name}

    switch = self.create_from_api data.first
  end

  # create_from_api: Allows you to create a new switch directly from the JSON the API returns
  def self.create_from_api(h, user = nil)
    unless h.has_key? 'light_bulb_id' # If the passed hash doesn't have this key, it's a light or some other kind of device
      return nil
    end

    @@user = user
    return self.new h['uuid'], h['light_bulb_id'], h['name'], h['last_reading']
  end

  # uuid = standard uuid
  # id = int assigned by wink for each device
  # name = friendly name I gave the device
  # device_state = powered/unpowered (should be either bool or on/off)
  attr_accessor :uuid, :id, :name, :device_state

  def initialize(uuid, id, name, lastest_hash)
    # h is a hash containing data returned by the Wink API
    @uuid = uuid
    @id = id
    @name = name

    @device_state = LightState.create_from_api lastest_hash

    # Now add this switch to the list of all lights
    @@lights.push self
  end

  def on
    @device_state.on # first, make sure the light is set to on
    update
  end

  def off
    @device_state.off
    update
  end

  def print
    puts "------------------ SWITCH ------------------"
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
      method: :put,
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

  # ------ SWITCHSTATE ---------------------------------------------------
  # ----------------------------------------------------------------------
  # ----------------------------------------------------------------------

  # This inner class holds the state of a switch and acts upon it

  class LightState

    attr_accessor :powered, :hash

    def self.create_from_api(h)
      return self.new h['powered'], h
    end

    def initialize(powered, api_hash = nil)
      # State should be a hash that comes from the Wink API
      @hash = api_hash

      # Now store the attributes we care about
      @powered = powered

    end

    def toggle
      case @powered.to_lower
      when "on", true
        @powered = false
      when "off", false
        @powered = true
      end
    end

    def on
      @powered = true
    end

    def off
      @powered = false
    end

    def prepare_for_api
      prepped = {
        desired_state: {
          powered: @powered
        }
      }

      prepped.to_json
    end

  end

end
