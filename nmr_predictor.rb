# nmr_predictor.rb - 1H-NMR Prediction class

require_relative 'iupac_name'

module NMR
  # =Predictor
  # ==Using Predictor
  # Predictor's constructor is a string representation of an alkane using IUPAC nomenclature.
  #   predictor = Predictor.new('2,4-diethylheptane')
  #   predictor = Predictor.new('2-methylbutane')
  #
  # Predictor will then use chemical information from
  # the IUPACName class to generate signals.
  class Predictor
    attr_reader :signal_names

    def initialize(name)
      @iupac_name = IUPACName.new(name)
      @signal_names = []
      self.predict
    end

    # Store signal names.
    def predict
      @iupac_name.signals.each do | signal |
        @signal_names.push SIGNAL_NAMES[signal]
      end
    end

    SIGNAL_NAMES = {
      1 => 'singlet',
      2 => 'doublet',
      3 => 'triplet',
      4 => 'quartet',
      5 => 'pentet',
      6 => 'sextet',
      7 => 'heptet',
      8 => 'octet',
      9 => 'nonet'
    }
  end
end

