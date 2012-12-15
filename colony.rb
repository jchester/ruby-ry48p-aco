require 'ant'

class Colony
  attr_reader :best_path
  
  def initialize( number_of_ants, pheromonal_strength, evaporation_rate )
    @pheromonal_strength = pheromonal_strength
    @evaporation_rate    = evaporation_rate / 100.0 # turn into fractional amount

    @nodes = []
    0.upto(47) { |i| @nodes << Node.new( i ) }

    @number_of_ants = number_of_ants
    new_ants
  end
  
  def iteration
    new_ants
    
    (0).upto(47) { @ants.each { |ant| ant.step } }

    iteration_best_path = @ants.min_by { |ant| ant.path.distance }.path
    
    if @best_path.nil?
      @best_path = iteration_best_path
    elsif iteration_best_path.distance < @best_path.distance
      @best_path = iteration_best_path
    end

    @nodes.each { |node| node.evaporate( @evaporation_rate ) }
    lay_pheromones
  end
  
  def node( number )
    @nodes.select { |n| n.number == number }[0] 
  end
  
  def shortest_distance
    @best_path.distance
  end
  
  def average_distance
    @ants.inject(0){ |sum,ant| sum += ant.path.distance } / @ants.size
  end
  
  private
    def new_ants
      @ants = []
      1.upto( @number_of_ants ) { @ants << Ant.new( @nodes.choice, self ) }
    end
    
    def lay_pheromones
      @ants.each { |ant| ant.path.lay_pheromones( @pheromonal_strength ) }
    end
end