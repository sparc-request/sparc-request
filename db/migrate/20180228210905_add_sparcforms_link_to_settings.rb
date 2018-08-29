class AddSparcformsLinkToSettings < ActiveRecord::Migration[5.1]
  def up
    if setting = Setting.find_by_key('navbar_links')
      navbar_links = setting.value
      unless navbar_links['sparc_forms']
        navbar_links['sparc_forms'] = ["SPARCForms", (Setting.get_value('root_url') + "/surveyor/responses")]
        setting.update_attribute(:value, navbar_links)
      end
    end
  end

  def down
    if setting = Setting.find_by_key('navbar_links')
      navbar_links = setting.value
      if navbar_links['sparc_forms']
        navbar_links.delete('sparc_forms')
        setting.update_attribute(:value, navbar_links)
      end
    end
  end
end
