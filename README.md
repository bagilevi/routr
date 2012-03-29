# Routr

[![Build Status](https://secure.travis-ci.org/bagilevi/routr.png)](http://travis-ci.org/bagilevi/routr)

Implements Dijkstra's algorithm to find the shortest path in a graph.

The cost of an edge can be more general than just a numeric value.
You can inject a method for calculating the distance from source to the
next node given the distance from source to the current node and the
properties of an edge. A possible use case is the one used by PeerPost:
nodes are people, an edge is a connection between specifying when those
people regularly meet, you inject a method that calculates when people
meet next after a specified time.

# Usage

```
class MyInterface
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

  def calculate_new_distance(distance_so_far, a_key, b_key)
    distance_so_far + NETWORK[a_key][b_key]
  end
end

route = Routr.new(MyInterface.new).calculate_route(
  :from => 'A',
  :to => 'D',
  :initial_distance => 0
)

route.hops.count       # => 2
route.members.count    # => 3

route.hops.first.from     # => 'A' 
route.hops.first.to       # => 'B' 
route.hops.first.distance # => 50
route.hops.last.from      # => 'B' 
route.hops.last.to        # => 'D' 
route.hops.last.distance  # => 100

route.members.first      # => 'A'
route.members.last       # => 'D'

route.distance   # => 100
```

If you have normal addible edge costs, you can replace the
`calculate_new_distance` method with `edge_distance`:

```
def edge_cost(a_key, b_key)
    NETWORK[a_key][b_key]
  end
```

# License

Copyright 2012, Levente Bagi

Released under the MIT License, see the LICENSE file.

