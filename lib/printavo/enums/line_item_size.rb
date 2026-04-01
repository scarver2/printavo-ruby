# lib/printavo/enums/line_item_size.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Garment size values for line items. Printavo supports a broad set of
    # industry-standard sizes; this list covers the most common values.
    module LineItemSize
      NONE       = 'NONE'
      OS         = 'OS'
      XS         = 'XS'
      S          = 'S'
      M          = 'M'
      L          = 'L'
      XL         = 'XL'
      TWO_XL     = '2XL'
      THREE_XL   = '3XL'
      FOUR_XL    = '4XL'
      FIVE_XL    = '5XL'
      SIX_XL     = '6XL'
      YOUTH_XS   = 'YXS'
      YOUTH_S    = 'YS'
      YOUTH_M    = 'YM'
      YOUTH_L    = 'YL'
      YOUTH_XL   = 'YXL'
      TODDLER_2T = '2T'
      TODDLER_3T = '3T'
      TODDLER_4T = '4T'
      TODDLER_5T = '5T'
      INFANT_NB  = 'NB'
      INFANT_6M  = '6M'
      INFANT_12M = '12M'
      INFANT_18M = '18M'
      INFANT_24M = '24M'

      ALL = [
        NONE, OS,
        XS, S, M, L, XL, TWO_XL, THREE_XL, FOUR_XL, FIVE_XL, SIX_XL,
        YOUTH_XS, YOUTH_S, YOUTH_M, YOUTH_L, YOUTH_XL,
        TODDLER_2T, TODDLER_3T, TODDLER_4T, TODDLER_5T,
        INFANT_NB, INFANT_6M, INFANT_12M, INFANT_18M, INFANT_24M
      ].freeze
    end
  end
end
