module Portal::ServicesHelper
  def core_or_program_hash(ls)
    if ls.try(:[], 'core_id')
      {:core_id => ls['core_id']}
    else
      {:program_id => ls['program_id']}
    end
  end

  def program_or_core(ls, service)
    if ls.try(:[], 'core_id')
      service.build_core_by_core_id
    else
      service.build_program_by_program_id
    end
  end
end
