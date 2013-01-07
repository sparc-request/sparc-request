module Portal::ApplicationHelper
  
  def pretty_tag(tag)
    tag.to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase
  end

  def is_num?(str)
    Float(str)
  rescue ArgumentError
    false
  else
    true
  end

  def is_whole_number?(number)
    number.to_i == number ? true : false
  end

  def two_decimal_places(num)
    sprintf('%0.2f', num.to_f.round(2)) rescue nil
  end

  def application_title

  end

  def cents_to_dollars(cost)
    cost / 100.00 rescue nil
  end

  def boolean_to_image(boolean)
    case boolean
    when true then image_tag('accept.png')
    when false then image_tag('cancel.png')
    else nil
    end
  end

  # def document_download_link(link)
  #   link + "?alf_ticket=" + Document.ticket(Alfresco::Document::ALFRESCO_USER, Alfresco::Document::ALFRESCO_PASSWORD)
  # end

  def cancel_or_reset_changes(controller)
    case controller.controller_name
    when 'projects' then link_to "Cancel", root_path
    else link_to "Reset Changes", service_request_related_service_request_path, :anchor => '#project'
    end
  end

  def hidden_ssr_id(controller)
    controller.controller_name == 'related_service_requests' ? hidden_field_tag('ssr_id', params[:id]) : ''
  end

  def hidden_friendly_id(controller)
    controller.controller_name == 'related_service_requests' ? hidden_field_tag('friendly_id', @service_request.friendly_id) : ''
  end

  def pretty_ssr_id(project, ssr)
    pre_id = project.try(:id)
    ssr_id = ssr.try(:ssr_id)

    "#{pre_id}-#{ssr_id}"
  end

  def pretty_submitted_at(entity)
    entity.submitted_at.to_time.strftime("%D") rescue "Not Yet Submitted"
  end

  def display_user_role(user)
    user.role == 'other' ? user.role_other.humanize : user.role.humanize
  end
end
