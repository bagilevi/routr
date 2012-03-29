require "routr/version"

module Routr
  autoload :Interface, 'routr/interface'

  class << self
    def new(*args, &block)
      Routr::Interface.new(*args, &block)
    end
  end
end
