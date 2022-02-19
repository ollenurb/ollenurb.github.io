---
title: Simulating Fluids using Cellular Automaton
---

### The Game of Life

At least once in your life you have probably come across Conway's Game of Life.  GOL is a so-called
0-player game, which means that once the initial conditions of the game are determined, each
subsequent state is calculated based on a set of predefined rules, without requiring any input from the
player. In this sense, GOL has all the characteristics of a simulation. In fact, its purpose was to
demonstrate how complex patterns can emerge from the implementation of simple well-established
rules. The idea of the simulation is pretty simple: Imagine an infinite 2-Dimensional grid of cells,
where each cell can be either alive or dead. Given an initial configuration of cells, the next
simulation step is calculated by determining the state (Dead/Alive) of each cell, using the
following rules:

1. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
2. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
3. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

The cool thing about all of this is that these 4 simple rules actually forms a
discrete Turing-complete model of computation. At this point one may wonder if
it is possible to simulate any other complex behaviour by changing such rules
appropriately, and the answer is (unsurprisingly) yes. It turns out that GOL is
a particular case of cellular automaton among lots of other cellular automatons
particularly created to model complex behaviours that we can normally find in
biology, physics and chemistry. In particular, this simulation approach has
found applications in fluid modelling, giving birth to the Lattice-Boltzmann
Model.

### From Grid to Lattice

To introduce the Lattice-Boltzmann Model, we first need to introduce a
particular mathematical structure called *lattice*. There are different
interpretations of a lattice, but essentially we can identify a lattice as a
This is a test
$$
e = mc^2
$$
