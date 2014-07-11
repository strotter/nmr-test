# chain.rb - Defines the Chain data structure.

module NMR
  # =Chain
  # ==Using Chain
  # Chain's constructor takes an integer as the number of carbons on the parent chain.
  # To add a side chain:
  #   Chain.add_side_chain(carbon_position, carbon_count)
  # carbon_position being where it branches on the parent, and carbon_count
  # being how long the alkyl chain is.
  class Chain
    attr_reader :parent_chain, :side_chains, :parent_carbon_count

    # Generate a parent chain structure based on carbon number. [3, 2, 2, 3]
    def initialize(parent_carbon_count)
      unless parent_carbon_count.is_a?Integer
        raise ArgumentError, 'Parent carbon count must be integer only'
      end

      @parent_carbon_count = parent_carbon_count
      @parent_chain = []
      if (parent_carbon_count == 1)
        @parent_chain = [4]
      else
        (1..parent_carbon_count).each do |count|
          if (count == 1 or count == parent_carbon_count)
            @parent_chain.push 3
          else
            @parent_chain.push 2
          end
        end
      end
      @side_chains = []
    end

    # Add a side chain to the list, and decrement hydrogen count at said position.
    def add_side_chain(carbon_position, carbon_count)
      if @parent_chain[carbon_position-1] < 1
        raise ArgumentError, 'Carbon #' + carbon_position.to_s + ' already has two side chains.'
      end

      new_side_chain = []
      if carbon_count == 1
        new_side_chain.push 3
      else
        (carbon_count-1).times { new_side_chain.push 2 }
        new_side_chain.push 3
      end
      @side_chains.push [carbon_position, new_side_chain]

      # One less hydrogen if there's a side chain attached.
      @parent_chain[carbon_position-1] -= 1
    end

    # Yields the side chains of any position on the parent.
    def get_side_chains(carbon_position)
      @side_chains.each do |carbon_number, side_chain|
        yield side_chain if carbon_number == carbon_position
      end
    end
  end
end