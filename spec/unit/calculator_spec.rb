require "routr/calculator"

describe Routr::Calculator do
  it "calculates shortest path" do
    graph = Graph.new(
      :edges => [
        ["a","b", 5],
        ["b","c", 3],
        ["c","d", 1],
        ["a","d",10],
        ["b","d", 2],
        ["f","g", 1],
      ]
    )

    r = Routr::Calculator.new(graph)
    r.shortest_path("a", "a").should == %w(a)
    r.shortest_path("a", "b").should == %w(a b)
    r.shortest_path("a", "c").should == %w(a b c)
    r.shortest_path("a", "d").should == %w(a b d)
    r.shortest_path("a", "f").should == nil
    r.shortest_path("a", "g").should == nil
  end

  it "calculates shortest path for graph with custom costs" do
    graph = TimeGraph.new(
      :edges => [
        ["a","b","1200"], # a and b meet every day at 12:00 noon
        ["b","c","1300"],
        ["a","d","1215"],
        ["d","c","1230"],
        ["c","e","1245"],
        ["f","g","1400"],
        ["a","h","1100"],
        ["h","i","1000"],
      ]
    )
    #    h ---1000--- a ---1200--- b
    #    |            |            |
    #   1000         1215         1300
    #    |            |            |
    #    i            d ---1230--- c
    #                              |
    #                             1245
    #    f ---1400--- g            |
    #                              e
    #
    # Meeting times: 4 digits: hhmm (every day)
    # Actual times: 6 digits: ddhhmm
    # 001200 = day 0, 12:00 noon

    r = Routr::Calculator.new(graph)
    r.shortest_path("a", "a", "001200").should == %w(a)
    r.shortest_path("a", "b", "001200").should == %w(a b)
    r.shortest_path("a", "c", "001200").should == %w(a d c)
    r.shortest_path("a", "d", "001200").should == %w(a d)
    r.shortest_path("a", "e", "001200").should == %w(a d c e)
    r.shortest_path("a", "f", "001200").should == nil
    r.shortest_path("a", "g", "001200").should == nil
    r.shortest_path("a", "h", "001200").should == %w(a h)
    r.shortest_path("a", "i", "001200").should == %w(a h i)
  end
end


class Graph
  def initialize(attr)
    @edges = {}
    attr[:edges].each do |a, b, edge_info|
      @edges[a] ||= {}
      @edges[a][b] = edge_info
    end
  end

  def edge_cost a, b
    (@edges[a] && @edges[a][b]) || (@edges[b] && @edges[b][a])
  end

  def neighbours_of(node)
    (
      ( (@edges[node] && @edges[node].keys) || [] ) +
      @edges.keys.select{|k| @edges[k].keys.include?(node)}
    ).uniq
  end

end


class TimeGraph < Graph
  private :edge_cost

  def calculate_new_distance time_so_far, a, b
    meeting_time_i = edge_cost(a, b).to_i # it's not actually a cost, but that's where we store the meeting value
    time_of_day_so_far_i = time_so_far.to_i % 10000

    # meeting time today
    new_time_i = time_so_far.to_i + (meeting_time_i - time_of_day_so_far_i)

    # meeting time tomorrow
    new_time_i += 10000 if time_of_day_so_far_i > meeting_time_i

    new_time_i.to_s.rjust(6,"0")
  end
end

