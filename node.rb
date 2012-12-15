require 'ry48p'

class Node
  class Edge <
    Struct.new( 'Edge', :number, :distance, :pheromone )
  end

  attr_reader :edges, :number

  def initialize( number )
    @number = number
    @edges = []
    Ry48p::DATA[number, true].to_a.each_index do |i| # select column from matrix, iterate over rows
      length = Ry48p::DATA[number, i]
      @edges << Edge.new( i, length, 0.0 ) if length < 9999999 # add edges, except the edge to self
    end
  end
  
  def evaporate( evaporation_rate )
    @edges.each { |edge| edge.pheromone = edge.pheromone * (1 - evaporation_rate) }
  end
end

