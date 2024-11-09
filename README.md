# Ruby on Rails Game Of Life

This repo is meant as an exercise. It implements basic auth with the [devise gem](https://github.com/heartcombo/devise) and [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).

It uses turbo streams to compute the generations and update the view.

## Ruby and Rails versions

The ruby version used is 3.3.5, while the rails version is 8.0.0.rc2.

## Setup

Install gem dependencies with

```sh
bin/bundle
```

Generate a `credentials.yml.enc` and `master.key` files pair by running

```sh
rm config/credentials.yml.enc
rm config/master.key
bin/rails credentials:edit
```

> [!WARNING]  
> Care: the file `credentials.yml.enc` is in source control.

To setup the database, run

```sh
bin/rails db:setup
```

## Running the test suite

To run tests, run the command

```sh
bin/rails test
```

## Running the dev server

To run the app in dev mode

```sh
bin/rails tailwindcss:build
bin/rails server
```

Or, more simply, run

```sh
bin/dev
```

> [!IMPORTANT]  
> In some cases the rails dev server might start before tailwindcss:watch has finished its first build and you might encounter the error "Propshaft::MissingAssetError". In that case, simply wait until the first tailwindcss build has finished and reload the page.

## Running with docker

The easiest way to start the application is to use docker.

A production Dockerfile is provided with Rails itself, but I've also added a shell script to regenerate encryption keys, build the image and pass them to the docker image when started.

Simply run

```sh
sh start-docker-prodlike.sh
```

> [!IMPORTANT]  
> The shell script maps port 80 on the docker container to the hosts port 80. If you have that port already in use on your machine (maybe by a web server, for example) you can edit the file so that it maps the container port 80 to another host port. For example, you could edit the last line like this `docker run -p 3000:80 -e RAILS_MASTER_KEY="$KEY" -e SSL_FORCE="false" sephyld/ror-gol` in order to map it to the port 3000.

## Using the application

Signup and load a text file that adheres to the following format

```
Generation {generation}:
{rows} {columns}
{dots_and_stars_grid_matrix_rows_times_columns}
```

For example

```
Generation 3:
4 8
........
....*...
....*...
....*...
```

You can then press the play button to simulate the Game Of Life.

A random game state generation is included. Have fun.

## Running the console script

You can edit the `script/state.txt` file and run

```sh
ruby script/play.rb
```

This is a looping console application that computes the next generation and prints the grid in loop until stopped.

## Some additional considerations

### A "slimmer" state

The way I've decided to represent the game of life's state is by having a grid field. The grid contains alive cells and dead cells, however, I think something else could be done.

I was exploring (maybe I'll continue to explore it in the future) the idea of a "slim state". The state object would be the same, but instead of having a grid property, we'd have a dictionary of alive cells positions. This way, if the number of alive cells is small enough, the process of advancing to the next generation is going to be faster. For huge grids I believe it's safe to assume that both time performance and memory size are going to improve. That is if, again, the number of alive cells is small enough. How small? I don't know, I haven't done the math, but the assumption is easy to make since the current implementation checks each grid cell, resulting in O(n^2).

By using a dictionary of alive cells, during the computation of the next generation we only have to check if any of those cells is going to die and if any of the adjacent dead cells is going to respawn (since in order for a dead cell to change its state it needs to be near exactly 3 alive cells).

It would be something like this. Probably...

```rb
# assuming that the dictionary of alive cells uses an array of [row, col] for keys and stores the value true
def next_generation!
  dead_cells_ready_to_respawn = {}
  alive_cells_ready_to_die = {}
  @alive_cells.each do |position, value|
	row, col = position
	nearby_alive_cells_positions = get_nearby_alive_cells_position(@alive_cells, row, col)
	# both underpopulation and overpopulation cases
	if nearby_alive_cells_positions.lenght < 2 or nearby_alive_cells_positions > 3 then
  	alive_cells_ready_to_die[[row, col]] = true
	end
	dead_cells_ready_to_respawn = get_nearby_dead_cells_ready_to_respawn(@alive_cells, row, col, dead_cells_ready_to_respawn) #we pass the fourth argument in order to keep adding elements to it. More like adding keys
  end

  dead_cells_ready_to_respawn.each do |position, value|
	@alive_cells[position] = true
  end
  alive_cells_ready_to_die.each do |position, value|
	@alive_cells.delete position
  end
end


def get_nearby_alive_cells_position(alive_cells, row, col)
  # check all 8 nearby positions and evaluate if they are in the alive_cells dictionary
  # I'm not going to implement this too
  # we don't need to have boundaries checks since if we are in position [0,0] the positions [-1, -1] to [-1, 1] and [-1, -1] to [1, -1] are just not going to be found in the dictionaries as keys
  # This applies for each "edge" cell
end

def get_nearby_dead_cells_ready_to_respawn(alive_cells, row, col, dead_cells_ready_to_respawn)
  # I'm not going to implement this either...
  # get the 8 nearby positions that are dead
  # this time we need to make a boundary check, and then...
  # check this out... :^)
  # call get_nearby_alive_cells_position for each dead cell to count the alive cells nearby
  #  # if the conditions to respawn are met
  #  # -> dead_cells_ready_to_respawn[position] = true
  # return dead_cells_ready_to_respawn
end
```

### The "Play" button issue

There is a potential problem with the play button: it causes the browser to make post requests to compute the next generation at a fixed rate. The crystal clear issue is... well... what if the requests take more time to compute?

The answer is, unfortunately, that those are headaches ready to be had.

### What about background jobs?

Another thing that could be done, potentially solving the issue stated above, is using background jobs to compute the next generation of the game state.

The browser could initiate a websocket connection and the play button could call an endpoint that would either start or "stop" a background job (those quotes are a surprise tool that will help us la- I'm not finishing the sentence, I'm already risking a lawsuit for even thinking that).

By pressing the play button, the browser starts a websocket connection using ActionCable. It also sends a request to an endpoint instructing the server to start a background job.

The background job will receive the info for the initial state and the websocket and loop as long as someone is connected to that same websocket. Inside this loop it will compute the next generation, and the next one, and the next one and so on.

At every computation, it will send a turbo_stream update to the client through that same websocket using ActionCable.

If my calculations are correct, which is a huge assumption, this will result in the same outcome.

I've already explored something **a little** similar in my repo [Overly-Complex Designed FizzBuzz (OCD FizzBuzz for short, pun intended)](https://github.com/sephyld/ocd-fizzbuzz). Have a look if you want.

Honestly... the continuous post requests are fine :)
