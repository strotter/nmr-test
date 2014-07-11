# iupac_name.rb - Contains data structures/parser for IUPAC nomenclature

require_relative 'chain'

module NMR
  # =IUPACName
  # ==Creating an IUPACName object
  # IUPACName's constructor takes a string representing standard IUPAC nomenclature
  #   NMR::IUPACName.new('2,4-diethylheptane')
  #   NMR::IUPACName.new('2-methyl-4-ethyloctane')
  # ==Using the IUPACName object
  # An IUPACName object will deconstruct the IUPAC name and generate
  # useful information about its chemical structure, including a list of NMR signals:
  #   IUPACName.new('methane').signals.each { |signal| puts signal }
  class IUPACName
    attr_reader :signals, :alkyl_groups

    def initialize(iupac_name)
      @iname = iupac_name.chomp
      @signals = self.parse
    end

    # Parses an alkane name, for example:
    # 2,2-dimethylhexane
    # 2-methylbutane
    def parse
      tname = @iname
      # Make sure it's an alkane.
      raise ArgumentError, 'Chemical name must be an alkane' unless tname =~ /ane$/

      # Truncate "ane"
      tname = tname.slice(0, tname.length-3)

      tname = build_parent_chain(tname)
      tname = get_alkyl_groups(tname)

      # Turn alkyl strings into side chains.
      generate_side_chains

      calculate_parent_chain_signals
      calculate_side_chain_signals

      @chain_signals.uniq
    end

  private

    def build_parent_chain(tname)
      CARBON_PREFIX.each do |name, carbon_count|
        if tname =~ /#{name}$/ then
          @chain = Chain.new(carbon_count)
          tname = tname.slice(0, tname.length-name.length)
          break
        end
      end

      tname
    end

    def get_alkyl_groups(tname)
      @alkyl_groups = []
      while true
        has_alkyl = false
        CARBON_PREFIX.each do |alkyl_name, carbon_count|
          if tname =~ /([0-9,]{1,5}-?(di|tri|tetra)?#{alkyl_name}yl)-?$/
            has_alkyl = true
            @alkyl_groups.push $1
            tname = tname.slice(0, tname.length-$1.length-1)
            tname ||= ''
          end
        end
        break unless has_alkyl
      end

      if tname.length > 0
        raise Exception, 'Invalid or ambiguous alkane name.'
      end

      tname
    end

    def generate_side_chains
      @alkyl_groups.each do |group|
        if group =~ /([\d,]+)-(di|tri|tetra)?(\w+)yl/
          prefix = $3
          if (CARBON_PREFIX.include?prefix)
            $1.split(',').each do |branch|
              @chain.add_side_chain(branch.to_i, CARBON_PREFIX[prefix])
            end
          end
        end
      end
    end

    # Calculate signals of parent chain and apply N+1 rule.
    def calculate_parent_chain_signals
      @chain_signals = []

      if (@chain.parent_carbon_count == 1)
        @chain_signals = [1] # Methane only has a lonely singlet.
      else
        (0..@chain.parent_carbon_count-1).each do |index|
          hydrogen_count = 0
          if index == 0 # Front
            hydrogen_count = @chain.parent_chain[index+1]
          elsif index == @chain.parent_carbon_count-1 # Back
            hydrogen_count = @chain.parent_chain[index-1]
          else # Side to side.
            # A group must have at least one hydrogen to count as a signal.
            if (@chain.parent_chain[index] > 0)
              hydrogen_count = @chain.parent_chain[index-1] + @chain.parent_chain[index+1]
              @chain.get_side_chains(index+1) do |side_chain|
                hydrogen_count += side_chain[0]
              end
            end
          end

          @chain_signals.push hydrogen_count+1 # N+1 rule
        end
      end
    end

    def calculate_side_chain_signals
      @chain.side_chains.each do |carbon, chain|
        (0..chain.length-1).each do |index|
          hydrogen_count = 0
          if index == 0 # Front of side chain, look at parent.
            hydrogen_count = @chain.parent_chain[carbon-1]
            # Also look to right if chain is longer than one.
            hydrogen_count += chain[index+1] if chain.length > 1
          elsif index == chain.length-1 # Back of chain, look to left only.
            hydrogen_count = chain[index-1]
          else # Look both ways if in the middle.
            hydrogen_count = chain[index-1] + chain[index+1]
          end

          @chain_signals.push hydrogen_count+1 # N+1 rule
        end
      end
    end

    CARBON_PREFIX = {
      'meth' => 1,
      'eth' => 2,
      'prop' => 3,
      'but' => 4,
      'pent' => 5,
      'hex' => 6,
      'hept' => 7,
      'oct' => 8,
      'non' => 9,
      'dec' => 10
    }

    IUPAC_NUMERIC_MULTIPLIER = {
      'mono' => 1,
      'di' => 2,
      'tri' => 3,
      'tetra' => 4,
      'penta' => 5,
      'hexa' => 6,
      'hepta' => 7,
      'octa' => 8,
      'nona' => 9,
      'deca' => 10,
      'undeca' => 11,
      'dodeca' => 12,
      'trideca' => 13,
      'tetradeca' => 14,
      'pentadeca' => 15,
      'hexadeca' => 16,
      'heptadeca' => 17,
      'octadeca' => 18,
      'nonadeca' => 19,
      'icosa' => 20,
      'eicosa' => 20,
      'henicosa' => 21,
      'docosa' => 22,
      'tricosa' => 23,
      'triconta' => 30,
      'hentriconta' => 31,
      'dotriaconta' => 32,
      'tetraconta' => 40,
      'pentaconta' => 50,
      'hexaconta' => 60,
      'heptaconta' => 70,
      'octaconta' => 80,
      'nonaconta' => 90,
      'hecta' => 100,
      'dicta' => 200,
      'tricta' => 300,
      'tetracta' => 400,
      'pentacta' => 500,
      'hexacta' => 600,
      'heptacta' => 700,
      'octacta' => 800,
      'nonacta' => 900,
      'kilia' => 1000,
      'dilia' => 2000,
      'trilia' => 3000,
      'tetralia' => 4000,
      'pentalia' => 5000,
      'hexalia' => 6000,
      'heptalia' => 7000,
      'octalia' => 8000,
      'nonalia' => 9000
    }
  end
end
