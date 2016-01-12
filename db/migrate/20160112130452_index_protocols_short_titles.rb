class IndexProtocolsShortTitles < ActiveRecord::Migration
  def change
    Protocol.bulk_update_fuzzy_short_title
  end
end
