# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require "activerecord-import"

namespace :data do 
  desc "Benchmarks for different active record insertions"
  task :visit_benchmark => :environment do
    ARM = Arm.create
    CONN = ActiveRecord::Base.connection
    TIMES = 200

    NOW = Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')
    LOOP= 10
    def mass_create_visit_group
      # vg = TIMES.times.map { VisitGroup.create(:arm_id => ARM.id) }
      vg_columns = [:arm_id]
      vg_values = []
      TIMES.times do
        vg_values.push [ARM.id]
      end
      VisitGroup.import vg_columns, vg_values

      ARM.reload
      vgs = ARM.visit_groups.select { |vg| vg.visits.count == 0 }

      vs = []
      LOOP.times do
        TIMES.times do |index|
          # Store the values for the new visits [line_items_visit_id, visit_group_id]
          vs.push "(#{vgs[index].id}, '#{NOW}', '#{NOW}')"
        end
      end

      sql = "INSERT INTO visits (`visit_group_id`, `created_at`, `updated_at`) VALUES #{vs.join(", ")}"
      CONN.execute sql
    end

    # def audit_add
    #   vs = []
    #   vg = TIMES.times.map { VisitGroup.create(:arm_id => ARM.id) }

    #   audit = []# does this need to be new columns or is it added automatically? 
    #   TIMES.times do |index|
    #     # Store the values for the new visits [line_items_visit_id, visit_group_id]
    #     vs.push "(#{vg[index].id}, '#{NOW}', '#{NOW}')"
    #     audit.push"(#{vg[index].id},'visit', null, null,null,null, 'create', '---quantity: 0\nbilling: \ndeleted_at: \nresearch_billing_qty: 0\ninsurance_billing_qty: 0\neffort_billing_qty: 0\nline_items_visit_id: 17261\nvisit_group_id:#{vg[index].id}, 1,null, null, #{NOW})" 
    #   end

    #   sql = "INSERT INTO visits (`visit_group_id`, `created_at`, `updated_at`) VALUES #{vs.join(", ")}"
    #   sql2 = "INSERT INTO audits ('auditable_id','auditable_type','associated_id','associated_type','user_id', 'user_type','username', 'action','audited_changes','version','comment','remote address','created_at') VALUES #{audit.join(", ")}"
    #   CONN.execute sql
    #   CONN.execute sql2
    # end 

    def do_inserts
      vg = TIMES.times.map { VisitGroup.create(:arm_id => ARM.id) }
      LOOP.times do
        TIMES.times { |index| Visit.create(:visit_group_id=> vg[index].id) }
      end
    end 

    # def raw_sql
    #   # vg = TIMES.times.map { VisitGroup.create(:arm_id => ARM.id) }
    #   vg_columns = [:arm_id]
    #   vg_values = []
    #   TIMES.times do
    #     vg_values.push [ARM.id]
    #   end
    #   VisitGroup.import vg_columns, vg_values

    #   ARM.reload
    #   vgs = ARM.visit_groups.select { |vg| vg.visits.count == 0 }

    #   LOOP.times do
    #     TIMES.times{ |index| CONN.execute "INSERT INTO visits (`visit_group_id`, `created_at`, `updated_at`) VALUES(#{vgs[index].id}, '#{NOW}', '#{NOW}')"}
    #   end
    # end

    def activerecord_import_mass_insert(validate = true)
      # vg = TIMES.times.map { VisitGroup.create(:arm_id => ARM.id) }
      vg_columns = [:arm_id]
      vg_values = []
      TIMES.times do
        vg_values.push [ARM.id]
      end
      VisitGroup.import vg_columns, vg_values, {:validate => validate}

      ARM.reload
      vgs = ARM.visit_groups.select { |vg| vg.visits.count == 0 }

      columns = [:visit_group_id]
      values = []
      LOOP.times do
        TIMES.times do |index|
          values.push [vgs[index].id]
        end
      end
      Visit.import columns, values, {:validate => validate}
    end 

    def activerecord_import_mass_insert_id_array(validate = true)
      vg_columns = [:arm_id]
      vg_values = []
      TIMES.times do
        vg_values.push [ARM.id]
      end
      VisitGroup.import vg_columns, vg_values, {:validate => validate}

      ARM.reload
      vgs = []
      ARM.visit_groups.select do |vg| 
        if vg.visits.count == 0
          vgs.push(vg.id)
        end
      end

      columns = [:visit_group_id]
      values = []
      LOOP.times do
        TIMES.times do |index|
          values.push [vgs[index]]
        end
      end
      Visit.import columns, values, {:validate => validate}
    end

    # def activerecord_import_mass_insert_new(validate=true)
    #   # vg = TIMES.times.map { VisitGroup.create(:arm_id => ARM.id) }
    #   vg_columns = [:arm_id]
    #   vg_values = []
    #   TIMES.times do
    #     vg_values.push [ARM.id]
    #   end
    #   VisitGroup.import vg_columns, vg_values, {:validate => validate}

    #   ARM.reload
    #   vgs = ARM.visit_groups.select { |vg| vg.visits.count == 0 }

    #   values = []
    #   LOOP.times do
    #     TIMES.times do |index|
    #       values.push Visit.new(:visit_group_id => vgs[index].id)
    #     end
    #   end
    #   Visit.import values, {:validate => validate}
    # end




    puts "Testing various insert methods for #{TIMES} inserts\n"
    puts "ActiveRecord without transaction:"
    puts base = Benchmark.measure {do_inserts}

    # puts "ActiveRecord with transaction:"
    # puts bench = Benchmark.measure { ActiveRecord::Base.transaction { do_inserts } }
    # puts sprintf("  %2.2fx faster than base", base.real / bench.real)

    # puts "Raw SQL without transaction:"
    # puts bench = Benchmark.measure { raw_sql }
    # puts sprintf("  %2.2fx faster than base", base.real / bench.real)

    # puts "Raw SQL with transaction:"
    # puts bench = Benchmark.measure { ActiveRecord::Base.transaction { raw_sql } }
    # puts sprintf("  %2.2fx faster than base", base.real / bench.real)

    # puts "Single mass insert:"
    # puts bench = Benchmark.measure { mass_create_visit_group }
    # puts sprintf("  %2.2fx faster than base", base.real / bench.real)

    # puts "ActiveRecord::Import mass insert:"
    # puts bench = Benchmark.measure { activerecord_import_mass_insert }
    # puts sprintf("  %2.2fx faster than base", base.real / bench.real)

    # puts "ActiveRecord::Import mass insert without validations:"
    # puts bench = Benchmark.measure { activerecord_import_mass_insert(false)  }
    # puts sprintf("  %2.2fx faster than base", base.real / bench.real)

    puts "ActiveRecord::Import new mass inserts by storing data in an array and placing it in an array:"
    puts bench = Benchmark.measure { activerecord_import_mass_insert}
    puts sprintf("  %2.2fx faster than base", base.real / bench.real)

    puts "ActiveRecord::Import new mass insert by getting visits out of array storage instead of db:"
    puts bench = Benchmark.measure { activerecord_import_mass_insert_id_array}
    puts sprintf("  %2.2fx faster than base", base.real / bench.real)

    # puts "Adding audit data with mass insert:"
    # puts bench = Benchmark.measure {audit_add}
    # puts sprintf("  %2.2fx faster than base", base.real / bench.real)

    ARM.destroy
  end
end
