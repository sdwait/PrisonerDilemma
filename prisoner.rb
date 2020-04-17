#This program is written in Ruby 2.7.1 
#Some code used for Question 3 is commented out, you can see it if you'd like.

### INITIALIZATION
N = 100
M = 5
P = 5
K = 20
CSV = false # Make it easy to import into excel?

### CLASS BACKBONE
class Player 
    attr_reader :nextChoice, :totalPayoff
    def initialize
        reset
    end

    def reset
        @totalPayoff = 0
        @nextChoice = :Cooperate
    end

    def determineNextChoice(otherPlayersChoice)
    end

    def processResult(otherPlayersChoice)
        if(otherPlayersChoice == :Cooperate)
            @totalPayoff += (@nextChoice == :Cooperate ? 3 : 5)
        else
            @totalPayoff += (@nextChoice == :Cooperate ? 0 : 1)
        end

        determineNextChoice(otherPlayersChoice)
    end
end

class TitForTat < Player
    def determineNextChoice(otherPlayersChoice)
        @nextChoice = otherPlayersChoice
    end
end

class Grudger < Player
    def determineNextChoice(otherPlayersChoice)
        if otherPlayersChoice == :Defect
            @nextChoice = :Defect
        end
    end
end

class AlwaysCooperate < Player
end

class AlwaysDefect < Player
    def reset
        super
        @nextChoice = :Defect
    end
end


def RunGame( p1, p2 )
    p1Decision = p1.nextChoice
    p2Decision = p2.nextChoice
    p1.processResult(p2Decision)
    p2.processResult(p1Decision)
end

## RECORDKEEPER

class PlayerData
    attr_accessor :how_many, :sum_payoff
    def initialize
        @how_many = 0
        @sum_payoff = 0
    end

end

class Record 
    def initialize(generation, pool)
        @generation = generation
        @t4t = PlayerData.new
        @g = PlayerData.new
        @ac = PlayerData.new
        @ad = PlayerData.new
        @totalPayoff = 0
        @totalSize = pool.length

        pool.each do |player| 
           @totalPayoff += player.totalPayoff
           case player.class.name
           when 'TitForTat'
            @t4t.how_many += 1
            @t4t.sum_payoff += player.totalPayoff
           when 'AlwaysDefect'
            @ad.how_many += 1
            @ad.sum_payoff += player.totalPayoff
           when 'AlwaysCooperate'
            @ac.how_many += 1
            @ac.sum_payoff += player.totalPayoff
           when 'Grudger'
            @g.how_many += 1
            @g.sum_payoff += player.totalPayoff
           end 
        end
    end

    def print_percent_pop
        t4tcent = (@t4t.how_many.to_f / @totalSize * 100).round(2)
        gcent = (@g.how_many.to_f / @totalSize * 100).round(2)
        adcent =(@ad.how_many.to_f / @totalSize * 100).round(2)
        accent = (@ac.how_many.to_f / @totalSize * 100).round(2)

        if CSV
            puts "#{@generation}, #{t4tcent},#{gcent},#{accent},#{adcent}"
        else
            puts "Gen #{@generation} T4T: #{t4tcent}%    G: #{gcent}%    AC: #{accent}%    AD: #{adcent}%"
        end
    end

    def print_avg_payoff
        t4tadv = (@t4t.sum_payoff.to_f / @t4t.how_many).round(2) 
        gadv = (@g.sum_payoff.to_f / @g.how_many).round(2)
        adadv =(@ad.sum_payoff.to_f / @ad.how_many ).round(2)
        acadv = (@ac.sum_payoff.to_f / @ac.how_many ).round(2)

        t4tadv = 0.0 if t4tadv.nan?
        gadv = 0.0 if gadv.nan?
        adadv = 0.0 if adadv.nan?
        acadv = 0.0 if acadv.nan?

        if CSV
            puts "#{@generation},#{t4tadv},#{gadv},#{acadv},#{adadv}"
        else
            puts "Gen #{@generation} T4T: #{t4tadv}    G: #{gadv}    AC: #{acadv}    AD: #{adadv}"
        end
    end
    def print_sum_payoff
        if CSV
            puts "#{@generation},#{@t4t.sum_payoff},#{@g.sum_payoff},#{@ac.sum_payoff},#{@ad.sum_payoff},#{@totalPayoff}"
        else
            puts "Gen #{@generation}   T4T: #{@t4t.sum_payoff}   G: #{@g.sum_payoff}   AC: #{@ac.sum_payoff}   AD: #{@ad.sum_payoff}   Total:#{@totalPayoff}"
        end
    end
end

# GENERATIONAL CHANGES

def MakeGenerationalChange(playerPool, percent)
    howManyToCull = Integer(N * percent/100.0)
    playerPool.sort!{ |a, b| b.totalPayoff <=> a.totalPayoff } # Sort high to low
    playerPoolBest = playerPool.take(howManyToCull)
    playerPoolBest.each{|player| playerPool.unshift(player.clone)} # Duplicate the top p%
    playerPool = playerPool.take(N) # Only keep the best N, dropping the bottom p%
    playerPool.each{|player| player.reset }
    return playerPool
end

def RunOneGeneration(playerPool)
    playerPool.combination(2) do |players|
        M.times{RunGame(players.first, players.last)}
    end
end

HowManyOfEachType = N/4;
#metarecords = []
##PREPARE TO RUN THE TESTS
#100.times do |currentP|
    ##CREATING THE INITIAL PLAYERPOOL
    pool = []

    #(N/3).times { pool << Grudger.new}
    #(N/3).times { pool << AlwaysDefect.new}
    #(N/3 + 1).times { pool << TitForTat.new}
    HowManyOfEachType.times{pool << AlwaysCooperate.new}
    HowManyOfEachType.times{pool << AlwaysDefect.new}
    HowManyOfEachType.times{pool << TitForTat.new}
    HowManyOfEachType.times{pool << Grudger.new}


    ## RUN THE TESTS
    records = []
    K.times do |i|
        RunOneGeneration(pool)
        records << Record.new(i, pool)
        #pool = MakeGenerationalChange(pool, currentP)
        pool = MakeGenerationalChange(pool, P)
    end
    #metarecords << records.last
#end
## PRINT THE RECORDS
puts "=============Percentage Records============="
puts "Generation,T4T,G,AC,AD" if CSV
records.each do |r|
#metarecords.each do |r|
    r.print_percent_pop
end

puts "===========Sum Payoffs =========="
puts "Generation,T4T,G,AC,AD,TotalPayoff" if CSV
records.each do |r|
#metarecords.each do |r|
    r.print_sum_payoff
end

puts "===========Average Payoffs =========="
puts "Generation,T4T,G,AC,AD" if CSV
records.each do |r|
#metarecords.each do |r|
    r.print_avg_payoff
end
