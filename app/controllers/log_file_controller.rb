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
    is_signed_in = user_signed_in?
  
    if is_signed_in
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
    if current_user.admin? == false
      uploaded_io = params[:log_file]

      saved_filename = Rails.root.join('public', 'uploads', "#{Time.new.strftime("%Y-%m-%d-%H%M%S")}_#{uploaded_io.original_filename}")

      File.open(saved_filename, 'wb') do |file|
        file.write(uploaded_io.read)
      end
    
      line_number = 0
      file_suffix = 1
    
      IO.foreach(saved_filename) do |line|
        if(line_number % 200 == 0)
          file_suffix = file_suffix + 1
        end

        File.open(Rails.root.join('public', 'uploads', "#{saved_filename}.split#{"%030d" % file_suffix}.log"), "a+") do |split_file|
          split_file.write(line)
        end

        line_number = line_number + 1
      
      end
    
      File.delete(saved_filename)
      processor = LogFileProcessor.new
      
      thr = Thread.new { processor.process_log_files() }
    end
  end
end
