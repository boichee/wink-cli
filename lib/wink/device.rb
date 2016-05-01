# device.rb
# Wink::Device

# The 'Device' class is something that I realized I needed after I basically had to
# copy the entire Switch class and create a nearly identical "Light" class.

# The Device class will either have to be a superclass of both of them so I can move shared code here,
# or it should be an Abstract class that uses methods that won't be defined until the Light and Switch classes
# But my gut tells me that an Abstract class would only make sense if there were methods that varied greatly between Light/Switch
# And that doesn't seem to be the case.

# In fact, I think the main differences are just the endpoints that are used and the key we look for when confirming a device to be of this type



require_relative './api'

# Within the current design, this is an ABSTRACT CLASS because it calls self.create_from_api but doesn't actually define that method

class Device
  # We'll keep track of all switches on a static property
  @@devices = Array.new
  @@user = nil

  # all: Provides a public getter for the @@devices static prop
  def self.all
    @@devices
  end

  def self.device_with_name(device_name)
    @@user = User.new(1, 2) # TODO: Rethink this. For now, you have to use the User class to make an API call. It's kind of weird
    data = @@user.all_devices
    data.select! {|x| x['name'] === device_name}

    self.create_from_api data.first # Creates and returns the new instance
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

    @device_state = DeviceState.create_from_api lastest_hash

    # Now add this switch to the list of all switches
    @@devices.push self
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
    puts "------------------ DEVICE ------------------"
    puts self
    puts "Name: #{@name}"
    puts "ID: #{@id}"
    puts "UUID: #{@uuid}"
    puts "Powered: #{@device_state.powered}"
    puts "--------------------------------------------"
    puts
  end

  # ------ SWITCHSTATE ---------------------------------------------------
  # ----------------------------------------------------------------------
  # ----------------------------------------------------------------------

  # This inner class holds the state of a switch and acts upon it

  class DeviceState

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
