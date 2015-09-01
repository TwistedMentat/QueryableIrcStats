class MessagesController < ApplicationController
  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.where("said_at > ?", 3.months.ago).order("said_at ASC").paginate(:page => params[:page])

    @hourly_stats = Array.new
    
    (0..23).each{ |hour|
      hourly_stat = HourlyStats.new
      hourly_stat.hour = hour
      hourly_stat.value = Message.where(:hour => hour).count
      @hourly_stats << hourly_stat
    }

    
    @words_per_hour = Array.new
    (0..23).each{ |hour|
      words_per_hour = HourlyStats.new
      words_per_hour.hour = hour
      words_per_hour.value = 0;
      Message.where(:hour => hour).each do |line|
        if line.message == nil then
          next
        end
        words_per_hour.value += line.message.squeeze(' ').split(%r{\s}).count
      end
      @words_per_hour << words_per_hour
    }


    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @message = Message.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message }
    end
  end
end
