# runs = 20
runs = 8
iterations = 20
# ants = [10, 100, 1000]
# ants = [100, 1000]
ants = [200]
evaporation = [ 5, 90 ]
pheromones = [ 0.5, 5.0 ]

total_experiments = ants.size * evaporation.size * pheromones.size 
experiment_number = 1
puts "Total experiments: #{total_experiments}"
experiment_number = 1

ants.each do |a|
  evaporation.each do |e|
    pheromones.each do |p|
      begin
        runstr = "ruby runner.rb -l -a #{a} -e #{e} -p #{p} -r #{runs} -i #{iterations}"
        puts "#{experiment_number} / #{total_experiments}: #{runstr}"
        # `#{runstr}`
        system "#{runstr} &" # controversial fork bomb variant
        sleep(2)
        experiment_number += 1
      rescue # Just keep going
        puts "\nAt #{experiment_number}, blew up on: #{runstr}"
        experiment_number += 1
        next
      end
    end
  end
end