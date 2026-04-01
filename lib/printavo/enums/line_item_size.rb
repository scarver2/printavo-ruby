# lib/printavo/enums/line_item_size.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Garment size values for line items. All values carry the +size_+ prefix
    # as returned by the Printavo V2 GraphQL API.
    module LineItemSize
      # Adult
      XS       = 'size_xs'
      S        = 'size_s'
      M        = 'size_m'
      L        = 'size_l'
      XL       = 'size_xl'
      TWO_XL   = 'size_2xl'
      THREE_XL = 'size_3xl'
      FOUR_XL  = 'size_4xl'
      FIVE_XL  = 'size_5xl'
      SIX_XL   = 'size_6xl'
      # Youth
      YOUTH_XS = 'size_yxs'
      YOUTH_S  = 'size_ys'
      YOUTH_M  = 'size_ym'
      YOUTH_L  = 'size_yl'
      YOUTH_XL = 'size_yxl'
      # Toddler
      TODDLER_2T = 'size_2t'
      TODDLER_3T = 'size_3t'
      TODDLER_4T = 'size_4t'
      TODDLER_5T = 'size_5t'
      # Infant
      INFANT_6M  = 'size_6m'
      INFANT_12M = 'size_12m'
      INFANT_18M = 'size_18m'
      INFANT_24M = 'size_24m'
      # Other
      OTHER = 'size_other'

      ALL = [
        XS, S, M, L, XL, TWO_XL, THREE_XL, FOUR_XL, FIVE_XL, SIX_XL,
        YOUTH_XS, YOUTH_S, YOUTH_M, YOUTH_L, YOUTH_XL,
        TODDLER_2T, TODDLER_3T, TODDLER_4T, TODDLER_5T,
        INFANT_6M, INFANT_12M, INFANT_18M, INFANT_24M,
        OTHER
      ].freeze
    end
  end
end
