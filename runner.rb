$stdout.sync = true

require 'pp'
require 'node'
require 'colony'
require 'rubygems'
require 'oyster'

SHORTEST_DISTANCE = 14422.0 # force to float for display purposes.

class Runner
  def initialize
    @cli_spec = Oyster.spec do
      name 'runner.rb -- ACO / ATSP runner'
      synopsis <<-EOS
        ruby runner.rb [options]
      EOS

      integer :ants,          :default => 10,      :desc => 'How many ants to use. Default 10.'
      integer :iterations,    :default => 10,      :desc => 'Iterations to perform. Default 10.'
      integer :pheromone,     :default =>  2,      :desc => 'Pheromonal strength. Performance-wise, values > 5 approximately equal 5. Default 2.'
      integer :evaporation,   :default => 25,      :desc => 'Percentage of pheromones evaporating per iteration. Default 25%.'
      integer :runs,          :default => 1,       :desc => 'How many runs of the GA to make. Default 1.'
      flag    :log,           :default => false,   :desc => 'Output logs for later analysis. Default false.'
      flag    :debug,         :default => false,   :desc => 'Crushing verbosity'

      author 'Jacques Chester 20304893'
    end
  end
  
  def run
    begin
      opts = @cli_spec.parse

      @number_ants         = opts[:ants]
      @iterations          = opts[:iterations]
      @pheromonal_strength = opts[:pheromone]
      @evaporation_rate    = opts[:evaporation]
      @runs                = opts[:runs]
      @log                 = opts[:log]
      @debug               = opts[:debug]
      
      @colony = Colony.new( @number_ants, @pheromonal_strength, @evaporation_rate )

      header

      @timestamp           = Time.now.strftime('%s')
      
      1.upto(@runs) do |run|
        logfile = nil
        if @log
          lfname = "logs/aco_#{@timestamp}_run_#{run}.csv"
          logfile = File.open( lfname, 'a' )
          logfile << header
          puts "Logging to #{lfname}"
        else
          puts header
        end

        1.upto(@iterations) do |iter|
          @colony.iteration
          @initial_distance = @colony.shortest_distance if iter == 1
          
          if @log
            logfile << log_line( iter )
          else
            print status_line( iter )
          end
          trap("INT") { puts footer("interrupted on #{iter}"); exit }
        end

        if @log
          logfile << footer('complete')
          logfile.close
        end
      end

      puts footer('complete') unless @log
    rescue Oyster::HelpRendered
      exit
    end
  end
  

  def status_line( iteration )
    shortest_distance = @colony.shortest_distance
    average_distance = @colony.average_distance
    percentage_best = (shortest_distance / SHORTEST_DISTANCE * 1.0)
    status_line = "        [%#{@iterations.to_s.length}u] \t\t%u\t\t%u\t\t(%2.4fx best)\n" % [iteration, average_distance, shortest_distance, percentage_best]
    
    @debug ? status_line + "\n" : status_line + "\r"
  end
  
  def log_line( iteration )
    shortest_distance = @colony.shortest_distance
    average_distance = @colony.average_distance
    "\n#{iteration},#{average_distance},#{shortest_distance}"
  end
  
  
  def header
"   # Commencing ant colony optimisation of ry48p ATSP problem at #{Time.now}.
   # Ants: #{@number_ants}
   # Iterations: #{@iterations}
   # Pheromonal strength: #{@pheromonal_strength}
   # Evaporation rate: #{@evaporation_rate}%
   # Initial Best Distance: #{@initial_distance}
   # Shortest known path distance: #{SHORTEST_DISTANCE.to_i}
   # #{'DEBUG ON' if @debug}
   # Iteration     Average Distance    Current Best
   # -----------------------------------------------------"
  end
  
  def footer( end_status )
    "\n   #------------------------------------------------------------------------------------------------------\n   # Run #{end_status}.\n   # #{Time.now}\n"
  end
end

Runner.new.run