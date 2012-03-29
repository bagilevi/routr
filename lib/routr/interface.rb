require 'routr/calculator'
module Routr
  class Interface
    def initialize interface
      @interface = interface
    end

    def calculate_route attr
      initial_distance = attr[:initial_distance] ||
        (@interface.initial_distance if @interface.respond_to?(:initial_distance)) ||
        0
      raw_route = Routr::Calculator.new(@interface)\
        .shortest_path(attr[:from], attr[:to], initial_distance, true)
      route = Route.from_raw(raw_route)
    end
  end


  class Route
    attr_reader :hops, :members, :distance, :raw

    def initialize(raw)
      @raw = raw
      raw ||= []
      @hops = raw[0..-2].to_enum.with_index.map{|item, index|
        Hop.new(
          :from => raw[index][:node],
          :to => raw[index + 1][:node],
          :distance => raw[index + 1][:distance]
        )
      }
      @members = raw.map{|item| item[:node]}
    end

    def self.from_raw(raw)
      new(raw)
    end

    def distance
      hops.last.distance
    end

    def found?
      @hops.any?
    end

    def missing?
      not found?
    end
  end


  class Hop
    attr_reader :from, :to, :distance
    def initialize(attributes)
      @from     = attributes[:from]
      @to       = attributes[:to]
      @distance = attributes[:distance]
    end
  end
end

