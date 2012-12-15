require 'path'

class Ant
  attr_reader :path
  
  def initialize( initial_node, colony )
    @path         = Path.new( initial_node )
    @current_node = initial_node
    @colony       = colony
  end
  
  def step
    # look at options
    # for each option
      # if visited already, ignore
      # if pheromones = 0, atractiveness = distance; add to visit candidates
      # if pheromones > 0, attractiveness = distance - (distance/pheromones); add to visit candidates
    # select an option from visit candidates proportional to attractiveness
    # push onto visited stack

    candidates = {}
    total_attractiveness = 0
    @current_node.edges.each do |edge|
      next if @path.seen?( edge )

      attractiveness = 0
      
      if edge.pheromone <= 0
        attractiveness = 1.0 / edge.distance
      else
        adjustment_factor = ( 1.9 / ( 1 + Math::E**(-edge.pheromone/2) ) ) - 0.95 # sigmoid function modified to start at 0.0 and max out at .
        adjustment_distance = (adjustment_factor * 1.0 * edge.distance).round
        
        # puts "distance: #{edge.distance}, adjustment factor: #{adjustment_factor}, adjustment distance: #{adjustment_distance}"
        
        attractiveness = 1.0 / (edge.distance - adjustment_distance)
      end
      
      # puts "edge: #{edge.number} distance: #{edge.distance} pheromones: #{edge.pheromone} attractiveness: #{attractiveness}"
      
      total_attractiveness += attractiveness
      candidates[edge.number] = attractiveness
    end
    
    # weighted random selection
    running_weight = 0
    n = rand * total_attractiveness
    selection = nil
    candidates.each do |num,weight|
      if n > running_weight && n <= running_weight+weight
        selection = num
        break
      end
      running_weight += weight
    end    
    next_node = @colony.node(selection)

    @path << next_node
    @current_node = next_node
  end
end