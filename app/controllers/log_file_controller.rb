class LogFileController < ApplicationController
  # GET /log_file/
  # GET /log_file/
  def view
    redirect_to action: 'new'
  end

  # GET /log_file/new
  # GET /log_file/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  # POST /log_files
  # 
  # Take the given file and save it to disc.
  def save
    uploaded_io = params[:log_file]

    saved_filename = Rails.root.join('public', 'uploads', "#{Time.new.strftime("%Y-%m-%d-%H%M%S")}_#{uploaded_io.original_filename}")

    File.open(saved_filename, 'w') do |file|
      file.write(uploaded_io.read)
    end
    
    processor = LogFileProcessor.new
    
    processor.process_log_file(saved_filename)
  end
end
