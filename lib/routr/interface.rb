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
    attr_reader :hops, :members, :distance

    def initialize(raw_route)
      raw_route ||= []
      @hops = raw_route[0..-2].to_enum.with_index.map{|item, index|
        Hop.new(
          :from => raw_route[index][:node],
          :to => raw_route[index + 1][:node],
          :distance => raw_route[index + 1][:distance]
        )
      }
      @members = raw_route.map{|item| item[:node]}
    end

    def self.from_raw(raw_route)
      new(raw_route)
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

