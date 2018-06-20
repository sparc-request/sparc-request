class ChangeIdsFromIntToBigint < ActiveRecord::Migration[5.1]
  def change
    # moved this to take lib/tasks/migrate_ids_to_bigint.rake since it breaks when model changes are made
    # might also be nice to be able to run this again
    say "#"*50
    say "#"*50
    say ""
    say "This migration has been moved to lib/tasks/migrate_ids_to_bigint.rake"
    say "Usage: rake migrate_ids_to_bigint"
    say ""
    say "#"*50
    say "#"*50
  end
end
