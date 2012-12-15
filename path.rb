require 'pp'

class Path
  attr_reader :distance
  
  def initialize( start )
    @nodes = [ start ]
    @distance = 0
  end
  
  def <<( new_node )
    @distance += @nodes.last.edges.select{ |e| e.number == new_node.number }[0].distance
    @nodes << new_node
  end
    
  def seen?( node )
    @nodes.include? node
  end
  
  def lay_pheromones( pheromonal_strength )
    edge_pheromone = pheromonal_strength / @distance
  
    0.upto( @nodes.length - 1 ) do |i|
      node = @nodes[i]
      next_node = @nodes[i+1]

      if !next_node.nil?
        edge = node.edges.select{ |e| e.number == next_node.number }[0]
        edge.pheromone += edge_pheromone
        
        # puts "edge pheremone: #{edge.pheromone}"        
      end
    end
  end
  
  def to_s
    str = ''
  
    @nodes.each do |node|
      str += "(#{node.number}) -> "
    end
    
    str += 'DONE'
  end
end