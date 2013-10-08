# test_predictor.rb - Unit Tests for the 1H-NMR Predictor

# $Id$

require 'test/unit'
require 'iupac_name'
require 'chain'
require 'nmr_predictor'

class TestNMRPredictor < Test::Unit::TestCase
  def test_iupac_parser
    iupac1 = NMR::IUPACName.new('butane')
    iupac2 = NMR::IUPACName.new('pentane')
    iupac3 = NMR::IUPACName.new('methane')
    iupac4 = NMR::IUPACName.new('propane')
    iupac5 = NMR::IUPACName.new('decane')
    assert_equal(iupac1.signals.sort, [3, 6])
    assert_equal(iupac2.signals.sort, [3, 5, 6])
    assert_equal(iupac3.signals.sort, [1])
    assert_equal(iupac4.signals.sort, [3, 7])
    assert_equal(iupac5.signals.sort, [3, 5, 6])
    assert_equal(NMR::IUPACName.new('2-methylhexane').signals.sort, [2, 3, 4, 5, 6, 9])
    assert_equal(NMR::IUPACName.new('2-ethylpropane').signals.sort, [2, 3, 5, 9])
    assert_equal(NMR::IUPACName.new('2-methylpropane').signals.sort, [2, 10])
    
    # Test the alkyl group parser.
    iupac6 = NMR::IUPACName.new('2-ethyl-3-methylhexane')
    assert_equal(iupac6.alkyl_groups, ['3-methyl', '2-ethyl'])
    
    iupac7 = NMR::IUPACName.new('2,2-diethylhexane')
    assert_equal(iupac7.alkyl_groups, ['2,2-diethyl'])
    
    iupac8 = NMR::IUPACName.new('2-ethyl-4,5-dipropylhexane')
    assert_equal(iupac8.alkyl_groups, ['4,5-dipropyl', '2-ethyl'])
  end
  
  def test_predictor
    p1 = NMR::Predictor.new('methane')
    assert_equal(p1.signal_names, ['singlet'])
    p2 = NMR::Predictor.new('propane')
    assert_equal(p2.signal_names.sort, ['heptet', 'triplet'])
    p3 = NMR::Predictor.new('2,2-diethylhexane')
    assert_equal(p3.signal_names.sort, ['pentet', 'quartet', 'sextet', 'singlet', 'triplet'])
  end
  
  def test_chain_structure
    chain1 = NMR::Chain.new(1)
    chain2 = NMR::Chain.new(2)
    chain3 = NMR::Chain.new(3)
    chain4 = NMR::Chain.new(4)
    chain5 = NMR::Chain.new(5)
    
    # Check initial parent chains.
    assert_equal(chain1.parent_chain, [4])
    assert_equal(chain2.parent_chain, [3, 3])
    assert_equal(chain3.parent_chain, [3, 2, 3])
    assert_equal(chain4.parent_chain, [3, 2, 2, 3])
    
    # Add side chains and ensure parent chain integrity.
    chain3.add_side_chain(2, 3)
    assert_equal(chain3.parent_chain, [3, 1, 3])
    assert_equal(chain3.side_chains, [[2, [2, 2, 3]]])
    
    chain5.add_side_chain(2, 1)
    assert_equal(chain5.parent_chain, [3, 1, 2, 2, 3])
    assert_equal(chain5.side_chains, [[2, [3]]])
    
    chain5.add_side_chain(2, 5)
    assert_equal(chain5.parent_chain, [3, 0, 2, 2, 3])
    assert_equal(chain5.side_chains, [[2, [3]], [2, [2, 2, 2, 2, 3]]])
  end
end

