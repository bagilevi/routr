require "routr/version"

module Routr
  autoload :Interface, 'routr/interface'
  autoload :Route, 'routr/interface'
  autoload :Hop, 'routr/interface'

  class << self
    def new(*args, &block)
      Routr::Interface.new(*args, &block)
    end
  end
end
