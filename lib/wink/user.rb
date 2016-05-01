
require_relative './api'


ALL_DEVICES = '/users/me/wink_devices'

def extract_data_from_response(d)
  JSON.parse(d)['data']
end

class User
  attr_accessor :username, :pw

  def initialize(u, p)
    @username = u
    @pw = p

    authenticate # TODO: When I have my own API key, authenticate will take the user info passed to .new and actually go get a token rather than just using the local environments key
  end

  # authenticates the user and gets a token to work with
  def authenticate
    @token = ENV['WINK_OAUTH_TOKEN']
  end

  def all_devices
    r = Wink::Request.new(ALL_DEVICES, @token)
    resp = r.run
    extract_data_from_response resp.body
  end

  def get_device(name)
    data = self.all_devices
    data.select! {|x| x['name'] === name}

    device = data.first

    if device.has_key? 'light_bulb_id'
      return Light.create_from_api(device, self)
    elsif device.has_key? 'binary_switch_id'
      return Switch.create_from_api(device, self)
    end
  end

  def get_switches
    data = self.all_devices

    data.map! { |x| Switch.create_from_api(x) }
    data.compact!

    return data

    devices = data.collect do |s|
      return Switch.create_from_api(s)
    end

    devices.compact! # Because some of the results of collect above won't be devices, we want to remove the nil elements that were created

    return devices
  end

  # This is a passthrough message for device classes to use
  def request(endpoint, options={})
    r = Wink::Request.new(endpoint, @token, options)

    resp = r.run
  end

end
