require 'pp'
require 'set'
require 'rubygems'
require 'fastercsv'
require 'narray'

FIXED_WIDTH_FONT = '/Library/Fonts/Andale Mono.ttf'

experiment_ids = Set.new

Dir.glob('logs/*').each do |filename|
  experiment_ids << filename.match(/\d+/)[0]
end

all_current_best_distances = {}
all_current_avg_distances  = {}

experiment_ids.each do |exp_id|
  begin
    runs = []
    current_best_positions = NMatrix.int( 8, 20 ) # 3 columns for runs, fifty rows for generations. 
    current_avg_positions  = NMatrix.int( 8, 20 )

    metadata = {}
    metadata_file = File.open( "logs/aco_#{exp_id}_run_1.csv", 'r' ).read # use this to get configuration of experiment
    
    metadata[:ants]          = metadata_file.match(/Ants: (\d+)/)[1]
    metadata[:pher_strength] = metadata_file.match(/strength: (\d+)/)[1]
    metadata[:evaporation]   = metadata_file.match(/rate: (\d+)/)[1]
    
    1.upto(8) do |run|
      csv_file = File.open( "logs/aco_#{exp_id}_run_#{run}.csv", 'r' ) # use this to extract data
    
      csv_string = ''
    
      csv_file.each do |line|
        csv_string << line unless line.match(/#/) or line.match(/^\s+$/)
      end
      csv_file.close

      rundata = FasterCSV.parse( csv_string )
      rundata.each do |row|
        run_index = run-1
        row_index = row[0].to_i - 1

        current_best_positions[run_index,row_index] = row[2].to_f # NMatrix is addressed in column,row order.
        current_avg_positions[run_index,row_index]  = row[1].to_f
      end
    end

    all_current_best_distances[exp_id] = [current_best_positions, metadata]
    all_current_avg_distances[exp_id]  = [current_avg_positions, metadata]
    
  rescue Errno::ENOENT
    puts "Experiment #{exp_id} has an incomplete set"
    next
  end
end

# pp all_current_best_distances

# Turn into gold
# Current best position
curr_best_pos_data = File.open( 'data/all_current_best_distances.data', 'a')
dat_str = ''
0.upto(19) do |row|
  all_current_best_distances.each do |exp_id,experiment|
    data = experiment[0]
    metadata = experiment[1]
    dat_str += "#{data[true,row].mean}\t#{data[true,row].stddev}\t"
  end
  dat_str += "\n"
end
curr_best_pos_data << dat_str
curr_best_pos_data.close

# Current average position

curr_avg_pos_data = File.open( 'data/all_current_avg_distances.data', 'a')
dat_str = ''
0.upto(19) do |row|
  all_current_avg_distances.each do |exp_id,experiment|
    data = experiment[0]
    metadata = experiment[1]
    dat_str += "#{data[true,row].mean}\t#{data[true,row].stddev}\t"
  end
  dat_str += "\n"
end
curr_avg_pos_data << dat_str
curr_avg_pos_data.close

# Make pretty pictures
curr_avg_pos_plot = File.open( 'data/combined.plot', 'a')
plt_str =  "set nokey\n"
plt_str += "unset bars\n"
plt_str += "set yrange[21500:]\n"
plt_str += "set term png font \"#{FIXED_WIDTH_FONT}\" 11 "
plt_str += "size 800,1000\n"
col = 1
all_current_avg_distances.each do |exp_id,experiment|
  data = experiment[0]
  metadata = experiment[1]
  
  plt_str += "set output 'graphs/#{exp_id}.png'\n"
  plt_str += "set multiplot layout 2,1 title "
  plt_str += "\"Experiment #{exp_id}\\n"
  plt_str += "Ants: #{metadata[:ants]}   "
  plt_str += "Pheromone Strength: #{metadata[:pher_strength]}   "
  plt_str += "Evaporation Rate : #{metadata[:evaporation]}\"\n"

  plt_str += "plot [0:20] 'data/all_current_best_distances.data' using :#{col}:#{col+1} with yerrorbars title 'Best individual path length' linestyle 1\n"
  plt_str += "plot [0:20] 'data/all_current_avg_distances.data' using :#{col}:#{col+1} with yerrorbars title 'Population average path length' linestyle 2\n"
  plt_str += "unset multiplot\n"
  col+=2
end
curr_avg_pos_plot << plt_str
curr_avg_pos_plot.close