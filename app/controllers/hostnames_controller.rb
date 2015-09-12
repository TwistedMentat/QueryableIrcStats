class HostnamesController < ApplicationController
  # GET /hostnames
  # GET /hostnames.json
  def index
    @hostnames = Hostname.order('domain_name asc')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @hostnames }
    end
  end

  # GET /hostnames/1
  # GET /hostnames/1.json
  def show
    @hostname = Hostname.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @hostname }
    end
  end

  private

  def hostname_params
  end
end
