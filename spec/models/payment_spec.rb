require 'spec_helper'

describe Payment do
  it{ should validate_numericality_of :amount_invoiced }
  it{ should validate_numericality_of :amount_received }
end
