# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
module Dashboard
  class DocumentRemover
    def initialize(id)
      document = Document.find(id)

      document.sub_service_requests = []

      document.destroy
    end
  end
end
