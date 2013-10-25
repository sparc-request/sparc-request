class SparcUsersReport < Report
  def self.description
  end

  def default_output_file
    return 'sparc_users_report.csv'
  end

  def assemble_users
    associated = Identity.joins(:project_roles).uniq! {|e| e.id}
    cms = Identity.joins(:catalog_managers).uniq! {|e| e.id}
    sps = Identity.joins(:service_providers).uniq! {|e| e.id}
    sus = Identity.joins(:super_users).uniq! {|e| e.id}

    all_users = (associated + cms + sps + sus).flatten.uniq! {|e| e.id}

    return all_users
  end

  def run
    header = [
      'Name',
      'Email'
    ]

    # Axlsx::Package.new do |p|
    #   p.workbook.add_worksheet(name: 'Report') do |sheet|
    #     sheet.add_row(header)
    #     self.assemble_users.each do |u|
    #       row = [
    #         u.full_name,
    #         u.email
    #       ]
    #       # puts row
    #       sheet.add_row(row)
    #     end
    #   end
    #   puts p.serialize
    #   p.serialize(@output_file)
    # end
    CSV.open(@output_file, 'wb') do |csv|
      csv << header
      self.assemble_users.each do |u|
        row = [
          u.full_name,
          u.email
        ]
          # puts row
        csv << row
      end
    end
  end
end