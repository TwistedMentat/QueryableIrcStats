class HostnamesController < ApplicationController
  # GET /hostnames
  # GET /hostnames.json
  def index
    @hostnames = Hostname.all

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

  # GET /hostnames/new
  # GET /hostnames/new.json
  def new
    @hostname = Hostname.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @hostname }
    end
  end

  # GET /hostnames/1/edit
  def edit
    @hostname = Hostname.find(params[:id])
  end

  # POST /hostnames
  # POST /hostnames.json
  def create
    @hostname = Hostname.new(params[:hostname])

    respond_to do |format|
      if @hostname.save
        format.html { redirect_to @hostname, notice: 'Hostname was successfully created.' }
        format.json { render json: @hostname, status: :created, location: @hostname }
      else
        format.html { render action: "new" }
        format.json { render json: @hostname.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /hostnames/1
  # PUT /hostnames/1.json
  def update
    @hostname = Hostname.find(params[:id])

    respond_to do |format|
      if @hostname.update_attributes(params[:hostname])
        format.html { redirect_to @hostname, notice: 'Hostname was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @hostname.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hostnames/1
  # DELETE /hostnames/1.json
  def destroy
    @hostname = Hostname.find(params[:id])
    @hostname.destroy

    respond_to do |format|
      format.html { redirect_to hostnames_url }
      format.json { head :no_content }
    end
  end
end
