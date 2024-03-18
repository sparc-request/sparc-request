# Copyright © 2011-2022 MUSC Foundation for Research Development
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
  def new_visit_group_button(arm, opts={})
    link_to new_visit_group_path(arm_id: arm.id, srid: opts[:srid], ssrid: opts[:ssrid], tab: opts[:tab], page: opts[:page], pages: opts[:pages]), remote: true, class: 'btn btn-success mr-1', title: t('visit_groups.new'), data: { toggle: 'tooltip' } do
      icon('fas', 'plus mr-2') + t('visit_groups.new')
    end
  end

  def delete_visit_group_button(visit_group, opts={})
    link_to visit_group_path(visit_group, srid: opts[:srid], ssrid: opts[:ssrid], tab: opts[:tab], page: opts[:page], pages: opts[:pages]), remote: true, method: :delete, class: 'btn btn btn-danger', title: t('visit_groups.delete'), data: { toggle: 'tooltip', confirm_swal: 'true' } do
      icon('fas', 'trash-alt mr-2') + t('visit_groups.delete')
    end
  end

  def visit_position_options(arm, visit_group, clone)
    # If the visit position has been changed, use the updated
    # position from the clone, otherwise use the original
    position      = visit_group.position && visit_group.position != clone.position ? clone.position : visit_group.position
    last_position = arm.visit_count

    if visit_group.position
      options_from_collection_for_select(arm.visit_groups.where.not(id: visit_group.id), Proc.new{ |vg| vg.position - 1 }, :insertion_name, position) +
      content_tag(:option, t(:constants)[:add_as_last], value: last_position, selected: position == last_position)
    else
      options_from_collection_for_select(arm.visit_groups.where.not(id: visit_group.id), Proc.new{ |vg| vg.position - 1 }, :insertion_name) +
      content_tag(:option, t(:constants)[:add_as_last], value: last_position)
    end
  end

  def move_visit_group_boundaries(visit_group, clone, arm)
    if visit_group.position
      # If the visit position has been changed, use the updated
      # position from the clone, otherwise use the original
      position        = visit_group.position && visit_group.position != clone.position ? clone.position : visit_group.position
      # See which visit group is at the current position to determine
      # how to calculate the min/max
      vg_at_position  = visit_group.position && (visit_group.new_record? || visit_group.position != clone.position) ? arm.visit_groups.find_by(position: position + 1) : visit_group

      if vg_at_position
        # Find the next closest previous visit with a day foor the minimum
        min = vg_at_position.higher_items.where.not(id: visit_group.id).where.not(day: nil).maximum(:day).try(:+, 1)
        max =
          # Visit has moved to a position between conseecutive days,
          # so min == max and there is only 1 option for the day
          if vg_at_position != visit_group && vg_at_position.day && vg_at_position.day == min
            vg_at_position.day
          # Visit has moved and there is no min or there is at least
          # 2 days between the min and the next visit group
          elsif vg_at_position != visit_group && vg_at_position.day && (min.nil? || vg_at_position.day > min)
            vg_at_position.day.try(:-, 1)
          # The visit has a blank day but is between two "consecutive" day visits
          # (which are therefore invalid) so the day must equal the day of the
          # next visit
          elsif (day = vg_at_position.lower_items.where.not(id: visit_group.id).where.not(day: nil).minimum(:day)) == min
            day
          # Otherwise the maximum day can be the next highest day
          # minus 1
          else
            day.try(:-, 1)
          end
      else
        # The only time this is hit is when you're moving a visit to the
        # very last position so get the maximum day + 1 if there is one
        min = arm.visit_groups.where.not(id: visit_group.id).where.not(day: nil).maximum(:day).try(:+, 1)
        max = nil
      end

      return min, max
    end
  end
end
