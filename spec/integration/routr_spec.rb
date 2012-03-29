require 'routr'

describe Routr do
  it "works for normal edge costs" do
    class SimpleInterface
      NETWORK = {
        'A' => { 'B' => 50, 'C' => 100 },
        'B' => { 'D' => 50 },
        'C' => { 'D' => 10 },
        'D' => {}
      }

      # This will be used if :initial_distance is not supplied to calculate_route
      def initial_distance
        0
      end

      def neighbours_of(node_key)
        NETWORK[node_key].keys
      end

      def edge_cost(a_key, b_key)
        NETWORK[a_key][b_key]
      end
    end
      
    route = Routr.new(SimpleInterface.new).calculate_route(
      :from => 'A',
      :to => 'D'
    )

    route.hops.count.should == 2
    route.members.count.should == 3

    route.hops.first.from.should == 'A' 
    route.hops.first.to.should == 'B' 
    route.hops.first.distance.should == 50
    route.hops.last.from.should == 'B' 
    route.hops.last.to.should == 'D' 
    route.hops.last.distance.should == 100

    route.members.first.should == 'A'
    route.members.last.should == 'D'

    route.distance.should == 100
  end

  it "works for custom edge costs" do

    # This example uses a simplified version of time.
    #
    # The values denote a time in a day when the two nodes 'meet',
    # where 1000 represents a whole day, i.e.
    #
    # A meets B at 500, 1500, 2500, etc.
    # A meets C at 100, 1100, 2100, etc.
    class CustomInterface
      NETWORK = {
        'A' => { 'B' => 300, 'C' => 600 },
        'B' => { 'D' => 400 },
        'C' => { 'D' => 700 },
        'D' => {}
      }

      def neighbours_of(node_key)
        NETWORK[node_key].keys
      end

      def calculate_new_distance(distance_so_far, a_key, b_key)
        time_of_day = distance_so_far % 1000
        beginning_of_day = distance_so_far - time_of_day
        meeting_time = NETWORK[a_key][b_key]
        if time_of_day <= meeting_time
          beginning_of_day + meeting_time
        else
          beginning_of_day + 1000 + meeting_time
        end
      end
    end
          
    route = Routr.new(CustomInterface.new).calculate_route(
      :from => 'A',
      :to => 'D',
      :initial_distance => 50_564
    )
    route.members.should == %w(A C D)
    route.distance.should == 50_700

    route = Routr.new(CustomInterface.new).calculate_route(
      :from => 'A',
      :to => 'D',
      :initial_distance => 50_900
    )
    route.members.should == %w(A B D)
    route.distance.should == 51_400
  end

  it "returns a missing route if not found" do
    route = Routr.new(SimpleInterface.new).calculate_route(
      :from => 'D',
      :to => 'A',
      :initial_distance => 0
    )
    route.hops.should == []
    route.members.should == []
    route.found?.should be_false
    route.missing?.should be_true
  end

  it "exposes the route as raw ruby" do
    route = Routr.new(SimpleInterface.new).calculate_route(
      :from => 'A',
      :to => 'D'
    )
    route.raw.should == [
      { :node => 'A', :distance => 0 },
      { :node => 'B', :distance => 50 },
      { :node => 'D', :distance => 100 },
    ]
  end
end

