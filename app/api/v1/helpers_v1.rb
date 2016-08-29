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

#Copyright © 2011-2016 MUSC Foundation for Research Development.
#All rights reserved.

module HelpersV1

  def update_service_line_items_count_attribute(params)
    if params.present?
      if params[:line_items_count].to_i > 0
        @object.class.increment_counter :line_items_count, @object.id
      elsif @object.line_items_count > 0
        @object.class.decrement_counter :line_items_count, @object.id
      end
    else
      error!("400 Bad request", 400)
    end
  end

  def presenter(klass, depth)
    submodule = [klass.classify, depth.classify].join

    ['V1', submodule].join('::').constantize
  end

  def find_object(klass, id)
    klass = klass.classify
    error!("#{klass} not found for id=#{id}", 404) unless @object = klass.constantize.where(id: id).first
  end

  def find_objects(klass, params)
    klass = klass.classify

    if params[:ids].any?
      @objects = klass.constantize.where(id: params[:ids])
    elsif params[:query].present?
      # identify invalid parameters (not found in the object)
      invalid_query_parameters = params[:query].select {|key, value| !klass.constantize.column_names.include? key }
      if invalid_query_parameters.present?
        error!("#{klass} query #{params[:query]} has the following invalid parameters: #{invalid_query_parameters.keys}", 400)
      elsif params[:limit] == 1 # return only one object, the first that meets the query criteria
        error!("#{klass} not found for query #{params[:query]}", 404) unless @object = klass.constantize.where(params[:query]).first
      else # return all objects that meet the query criteria
        @objects = klass.constantize.where(params[:query]).limit(params[:limit]) # a nil limit is ignored by ActiveRecord
      end
    else # only apply params[:limit] if params[:query] exists
      @objects = klass.constantize.all
    end
  end

  def current_user
    @current_user ||= User.authorize!(env)
  end

  def authenticate!
    error!('401 Unauthorized', 401) unless current_user
  end
end
