# Copyright © 2011-2019 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module VisitGroupsHelper
  def visit_position_options(arm, visit_group=nil, position=nil)
    last_position = arm.visit_groups.maximum(:position) + 1

    if visit_group
      position = position.blank? ? visit_group.position + 1 : position
      options_from_collection_for_select(arm.visit_groups.where.not(id: visit_group.id), :position, :insertion_name, position) +
      content_tag(:option, t(:constants)[:add_as_last], value: last_position, selected: position == last_position)
    else
      options_from_collection_for_select(arm.visit_groups, :position, :insertion_name) +
      content_tag(:option, t(:constants)[:add_as_last], value: last_position)
    end
  end

  def move_visit_group_boundaries(visit_group, arm, position)
    vg_at_position  = arm.visit_groups.find_by(position: position)

    if vg_at_position
      min = vg_at_position.higher_items.where.not(id: visit_group.id, day: nil).maximum(:day).try(:+, (vg_at_position.day.present? && vg_at_position.higher_item.try(:day).present? ? 0 : 1))
      max = vg_at_position.day.present? ? vg_at_position.day - 1 : vg_at_position.lower_items.where.not(id: visit_group.id, day: nil).minimum(:day).try(:-, 1)
    else
      min = arm.visit_groups.maximum(:day) + 1
      max = nil
    end

    return min, max
  end
end
