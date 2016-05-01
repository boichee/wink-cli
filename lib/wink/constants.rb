# constants.rb
# Wink::Constants

require 'ostruct'

# Provides some constants that are useful when working with the Wink API

module Wink
  # HTTP Method Constants
  # Methods = { GET: :get,
  #             POST: :post,
  #             PUT: :put,
  #             PATCH: :patch,
  #             DELETE: :delete }

  HttpMethods = OpenStruct.new
  HttpMethods.Get = :get
  HttpMethods.Post = :post
  HttpMethods.Put = :put
  HttpMethods.Patch = :patch
  HttpMethods.Delete = :delete

end
