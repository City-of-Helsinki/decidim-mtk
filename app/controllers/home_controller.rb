class HomeController < Decidim::ParticipatoryProcesses::ParticipatoryProcessesController
  def index
    show
    render :show
  end
end
