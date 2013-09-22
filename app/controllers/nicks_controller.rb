class NicksController < ApplicationController
  # GET /nicks
  # GET /nicks.json
  def index
    @nicks = Nick.order("name asc")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @nicks }
    end
  end

  # GET /nicks/1
  # GET /nicks/1.json
  def show
    @nick = Nick.find(params[:id])

    @hourly_stats = Array.new
    
    (0..23).each{ |hour|
      hourly_stat = HourlyStats.new
      hourly_stat.hour = hour
      hourly_stat.number_of_lines = Message.where(:hour => hour, :nick_id => @nick.id).count
      @hourly_stats << hourly_stat
    }

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @nick }
    end
  end

  # GET /nicks/new
  # GET /nicks/new.json
  def new
    @nick = Nick.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @nick }
    end
  end

  # GET /nicks/1/edit
  def edit
    @nick = Nick.find(params[:id])
  end

  # POST /nicks
  # POST /nicks.json
  def create
    @nick = Nick.new(params[:nick])

    respond_to do |format|
      if @nick.save
        format.html { redirect_to @nick, notice: 'Nick was successfully created.' }
        format.json { render json: @nick, status: :created, location: @nick }
      else
        format.html { render action: "new" }
        format.json { render json: @nick.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /nicks/1
  # PUT /nicks/1.json
  def update
    @nick = Nick.find(params[:id])

    respond_to do |format|
      if @nick.update_attributes(params[:nick])
        format.html { redirect_to @nick, notice: 'Nick was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @nick.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nicks/1
  # DELETE /nicks/1.json
  def destroy
    @nick = Nick.find(params[:id])
    @nick.destroy

    respond_to do |format|
      format.html { redirect_to nicks_url }
      format.json { head :no_content }
    end
  end
end
