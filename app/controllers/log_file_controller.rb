class LogFileController < ApplicationController
  before_action :authenticate_user!
  # GET /log_file/
  # GET /log_file/

  def view
    redirect_to action: 'new'
  end

  # GET /log_file/new
  # GET /log_file/new.json
  def new
    if current_user.can_upload_log?
      respond_to do |format|
        format.html # new.html.erb
      end
    else
      redirect_to :root
    end
    
  end
  
  # POST /log_files
  # 
  # Take the given file and save it to disc.
  def save
    if current_user.can_upload_log? == true
      @uploaded_files = params[:log_file]

      
      @uploaded_files.each{|uploaded_file| 
        saved_filename = Rails.root.join('public', 'uploads', "#{Time.new.strftime("%Y-%m-%d-%H%M%S")}_#{uploaded_file.original_filename}")

        Rails.logger.info "Saving uploaded file to #{saved_filename}"

        File.open(saved_filename, 'wb') do |file|
          file.write(uploaded_file.read)
        end

        Rails.logger.info "Saved uploaded file to #{saved_filename}"
        
      }
      processor = LogFileProcessor.new

      
      thr = Thread.new { processor.process_log_files() }
    else
      logger.warn "The current user \"#{current_user.email}\" is not able to upload a file."
    end
  end
end
