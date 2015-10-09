class Portal::EpicQueuesController < Portal::BaseController
  
  before_filter :get_epic_queue, :only => [:destroy]

  def index
    respond_to do |format|
      format.html {
        @epic_queues = EpicQueue.all

        render
      }
    end
  end

  def destroy
    respond_to do |format|
      format.js {
        @epic_queue.destroy

        render
      }
    end
  end

  private

  def get_epic_queue
    @epic_queue = EpicQueue.find(params[:id])
  end
end
