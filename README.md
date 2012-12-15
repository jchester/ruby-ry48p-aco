ruby-ry48p-aco
==============

A Ruby Ant Colony Optimiser for the ry48p TSP.

This is code I submitted as a student. It is not suitable for production usage.

Usage
=====

First, a warning: Ant Colony Optimisers written in Ruby by students are really, really slow.

    ruby multirun.rb
    ruby consolidate_data.rb
    gnuplot < data/combined.plot

This will run 75 experiments, consolidate the logged info and dump graphs of each experiment in graphs/.