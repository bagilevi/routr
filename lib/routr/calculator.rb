module Routr
  class Calculator

    def initialize(graph)
      @graph = graph
    end

    attr_reader :graph

    # based of wikipedia's pseudocode: http://en.wikipedia.org/wiki/Dijkstra's_algorithm

    def dijkstra(initial_node, initial_distance = 0)
      debug
      debug "== routing from #{initial_node.inspect}"
      initialize_temporary_variables

      set_distance(initial_node, initial_distance)
      add_unvisited_node(initial_node)

      while any_unvisited_nodes?
        u = node_with_minimum_distance
        break if not reachable? u
        mark_as_visited u

        with_each_neighbour_of u do |v| # for each neighbor v of u: where v has not yet been removed from Q.
          debug "neighbour: #{v}"
          new_distance = calculate_new_distance(best_distance_to(u), u, v)
          if (best_distance_to(v) == :infinity) || (new_distance < best_distance_to(v))
            set_best_distance_to(v, new_distance)
            add_unvisited_node(v)
            set_previous_node_to(v, u)
          end
        end
        debug
      end
      debug "== end routing"
    end

    def shortest_path src, dest, initial_distance = 0, include_details = false
      dijkstra src, initial_distance
      path_to dest, include_details
    end

    def path_to(dest, include_details = false)
      if reachable? dest
        item = \
          if include_details
            {
              :node => dest,
              :distance => best_distance_to(dest)
            }
          else
            dest
          end
        previous_path_to(dest, include_details) + [ item ]
      end
    end

    def previous_path_to(dest, include_details = false)
      if previous_node_to(dest).nil?
        []
      else
        path_to(previous_node_to(dest), include_details)
      end
    end


    private

    def edge_cost a, b
      (graph.edge_cost(a, b) || :infinity).tap { |cost|
        debug "Edge cost #{a} -> #{b} = #{cost.inspect}"
      }
    end

    def calculate_new_distance distance_so_far, a, b
      if graph.respond_to?(:calculate_new_distance)
        graph.calculate_new_distance distance_so_far, a, b
      else
        distance_so_far + edge_cost(a, b)
      end.tap {|new_distance|
        if new_distance < distance_so_far
          raise "New distance < previous distance: #{new_distance.inspect} < #{distance_so_far.inspect}"
        end
      }
    end

    def initialize_temporary_variables
      @d = {}
      @prev = {}
      @candidates = []
    end

    def best_distance_to(node)
      debug "best_distance[#{node.inspect}] # -> #{@d[node].inspect}"
      @d[node] || :infinity
    end

    def reachable?(node)
      debug "reachable?(#{node.inspect})"
      (best_distance_to(node) != :infinity)\
      .tap {|r| debug "=> #{r.inspect}" }
    end


    # OPTIMIZE: maintain a sorted list, so we don't have to search the whole set every time
    def node_with_minimum_distance # unvisited node with minimum distance
      debug "node_with_minimum_distance"
      @candidates.min_by{ |x| best_distance_to(x) }\
      .tap{|x| debug "=> #{x.inspect}"}
    end

    def mark_as_visited node
      @candidates = @candidates - [node]
    end

    def any_unvisited_nodes?
      debug "any_unvisited_nodes?"
      @candidates.any?\
      .tap{|r| debug "=> #{r.inspect}" }
    end

    def add_unvisited_node node
      debug "add_unvisited_node #{node.inspect}"
      @candidates << node
    end


    def set_distance node, value
      @d[node] = value           # Distance from source to source
    end

    def with_each_neighbour_of node, &block
      graph.neighbours_of(node).tap{|neighbours| debug "Neighbours of: #{node} -> #{neighbours.inspect}"}.each(&block)
    end

    def set_best_distance_to node, new_distance
      debug "best_distance[#{node.inspect}] = #{new_distance.inspect}"
      @d[node] = new_distance
    end

    def set_previous_node_to node, previous_node
      @prev[node] = previous_node
    end

    def previous_node_to(node)
      @prev[node]
    end

    def debug *args
      return
      @i ||= 0
      @i += 1
      if @i < 1000
        puts *args
      end
    end

  end
end

