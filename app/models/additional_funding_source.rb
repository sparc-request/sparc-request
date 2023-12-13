class AdditionalFundingSource < ApplicationRecord
  belongs_to :protocol

  validates :fundig_source_other, presence: true, if: Proc.new { |a| a.funding_source == 'Internal Funded Pilot Project' }

  validates :funding_source, presence: true

  def display_additional_funding_source_value
    source = "#{PermissibleValue.get_value('funding_source', funding_source)}"
    if funding_source_other.present?
      source += ": #{funding_source_other}"
    end
    return source
  end
  ## In case we decide to validate federal grant details ##
  # validates :federal_grant_code, :federal_grant_serial_number, :federal_grant_title, presence: true, if: Proc.new { |a| a.funding_source == 'Federal' }

  # validate :phs_or_non_phs_sponsor_present, if: Proc.new { |a| a.funding_source == 'Federal' }

  # def phs_or_non_phs_sponsor_present
  #   if phs_sponsor.blank? && non_phs_sponsor.blank?
  #     errors.add(:base, "Either PHS Sponsor or Non-PHS Sponsor must be present")
  #   elsif phs_sponsor.present? && non_phs_sponsor.present?
  #     errors.add(:base, "PHS Sponsor and Non-PHS Sponsor cannot both be present")
  #   end
  # end
end
