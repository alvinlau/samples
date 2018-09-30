require 'tty-prompt'
require 'terminal-table'
require 'pp'


# Helper methods ===============================================================

# returns 'die' for 1 and 'dice' for > 1
def plural dice
  dice == 1 ? 'die' : 'dice'
end


# roll n dice and return them in an array e.g. roll 5 => [3,4,6,2,1]
def roll n
  throw 'only roll 1-5 dice' if ( !(1..5).cover? n )
  (1..n).map { |i| Random.new.rand(1..6) }
end


# returns the score and remaining number of dice
# see here for alternative ways, but I chose the fastest one already
# http://carol-nichols.com/2015/08/07/ruby-occurrence-couting/
def score dice
  points = 0

  # look for triplets (well, at most one set in reality)
  if dice.size >= 3
    groups = dice.group_by { |val| val } # e.g. {1=>[1], 2=>[2,2,2], 5=>[5]}
    triplet = groups.find { |val, dups| dups.size >= 3 }

    if triplet # e.g. triplet => [2, [2,2,2]]
      value = triplet[0]

      # calculate the points
      bonus = {1 => 1000, 6 => 600, 5 => 500, 4 => 400, 3 => 300, 2 => 200}
      points += bonus[value]
      puts "Bonus for triple #{value}s! - #{bonus[value]} points!"

      # take away from the set of dice so the we can score the remaining ones
      # not the prettiest way I know...but then we only need to do it 3 times
      (1..3).each { |i| dice.delete_at dice.index(value) }
    end
  end

  # count (remaining) 1s and 5s
  dice.each do |val|
    points += 100 if val == 1
    points += 50 if val == 5
  end

  puts "Got a total of #{points} points for this roll!"

  # remove the 1s and 5s after they have been counted
  dice = dice.select {|val| ![1,5].include? val }

  {points: points, dice: dice.size}
end


# print out the current score for all players
# todo: highlight specified player
def show players
  rows = players.map { |player| [player[:name], player[:score]] }
  puts Terminal::Table.new headings: ['Player', 'Score'], rows: rows
end


# do multiple rolls until the player has decided to stop, or has lost their turn
def multiroll
  pr = TTY::Prompt.new
  # do rolls and add to <points>
  points = 0
  dice = 5
  reroll = true

  while reroll do
    pp (dice_set = roll dice)
    result = score dice_set

    # unlucky roll with no points
    if result[:points] == 0
      puts 'Unlucky! No more points this turn, sorry!'
      points = 0
      reroll = false
      break
    end

    # new points to be added
    points += result[:points]
    puts "#{points} points in this turn so far"
    # number of remaining dice
    dice = (result[:dice] == 0) ? 5 : result[:dice]

    reroll = pr.yes? "Roll again? #{dice} #{plural dice} remaining"
  end
  points
end


# Actual Game ==================================================================

# The structure to keep track of players will be an array of hashes
# e.g. [{name: 'john', score: 400}, {name: 'amy', score: 6000}, ...]
players = []
pr = TTY::Prompt.new

# collect players
start_game = false
until start_game do
  name = pr.ask 'Please enter player name:'
  players << {name: name, score: 0}

  unless players.size < 2
    start_game = pr.yes? 'Start game? Enter no to add more players'
  end
end


# start the actual agme
final_turn = false
round = 1
until final_turn == :now do
  if final_turn == :next
    final_turn = :now
    puts 'It is the final round! Everyone gets one last turn'
  else
    puts "Round #{round}! Good luck on your turn!"
  end

  # retotal each player's score base on their rolls and update it in the list
  # user map! to modify the list in place, hopefully not spill memory that way
  players = players.map! do |player|
    name = player[:name]
    pr.ask "==> #{name}'s turn, press enter to roll <=="

    # do rolls and get the total number of new points
    points = multiroll

    if points > 0
      # player can finally accumulate points
      if player[:score] < 300
        if points >= 300
          # puts "#{name} has gotten more than 300 points in a turn for first time"
          puts "#{name} is now 'In The Game'!"
        else
          puts "Sorry! Still need to get more than 300 points in a turn before accumulating points"
          points = 0
        end
      end

      # actually have new points to add from this turn's rolls
      new_score = player[:score] + points
      puts "#{name} got #{points} points in this turn, their new score is now #{new_score}!"
      if new_score >= 3000 && !final_turn
        final_turn = :next
        puts "#{name} has #{new_score} points! The next round will be the final round!"
      end
      {name: name, score: new_score}
    else # nothing to change if player got no points this turn
      puts "#{name} didn't get any points this turn, better luck next time!"
      player
    end
  end

  show players
  round += 1
end


# Show the final winner
puts "The game has ended!"
winner = players.sort_by { |player| player[:score] }.last
# show players
puts "The winner is...#{winner[:name]} with #{winner[:score]} points!"
