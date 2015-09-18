# Controller to handle nickname/handle related actions.
class NicksController < ApplicationController
  # GET /nicks
  # GET /nicks.json
  def index
    @nicks = Nick.order('name asc')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @nicks }
    end
  end

  # GET /nicks/1
  # GET /nicks/1.json
  def show
    @nick = Nick.find(params[:id])

    @hourly_stats = []

    (0..23).each do |hour|
      hourly_stat = HourlyStats.new
      hourly_stat.hour = hour
      hourly_stat.value = Message.where(hour: hour, nick_id: @nick.id).count
      @hourly_stats << hourly_stat
    end

    @number_of_words_per_hour = []
    (0..23).each do |hour|
      number_of_words_per_hour = HourlyStats.new
      number_of_words_per_hour.hour = hour
      number_of_words_per_hour.value = 0
      Message.where(hour: hour, nick_id: @nick.id).each do |line|
        next if line.message.nil?
        number_of_words_per_hour.value += line.message.squeeze(' ').split(/\s/).count
      end
      @number_of_words_per_hour << number_of_words_per_hour
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @nick }
    end
  end
end
