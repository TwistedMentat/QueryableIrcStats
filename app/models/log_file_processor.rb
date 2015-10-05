require 'active_support/core_ext'

# Contains all methods and actions needed to process a log file and add it into the database.
# Disabling this cop for this class as this class only does one thing at the moment. Processes a log file.
# Should we update it in the future to do more then we can strip out the specific processing bits into their own files.
# rubocop:disable ClassLength
class LogFileProcessor
  @day = 1
  @month = 'jan'
  @year = 2013

  def process_log_files
    uploads_to_process_folder = Rails.root.join('public', 'uploads')
    Rails.logger.info "Process folder #{uploads_to_process_folder}"
    files_to_process = Dir.glob(File.join(uploads_to_process_folder, '*.*'))
    files_to_process_sorted = files_to_process.sort_by { |filename| File.mtime(filename) }

    files_to_process_sorted.each do |filename|
      Rails.logger.info "#{Time.now.inspect} Processing file #{filename}"
      process_log_file(filename)
      File.delete(filename_of_log_file)
    end
  end

  ##
  # Process the provided log file and add the values into the database
  def process_log_file(filename_of_log_file)
    IO.foreach(filename_of_log_file) do |line|
      begin
        next if line.match(/^$/)

        if line.match(/^---/)
          log_unprocessable_line(line)
          line.match(/(\w\w\w) (\d\d)(?: \d\d:\d\d:\d\d)? (\d\d\d\d)/)
          @day = Regexp.last_match(2)
          @month = Regexp.last_match(1)
          @year = Regexp.last_match(3)
          next
        end

        if line.match(/^\d\d:\d\d -!-/)
          process_system_message(line)
          next
        end

        if line.match(/^\d\d:\d\d  \*/)
          process_emote(line)
          next
        end

        process_speech(line)

        if Regexp.last_match(1).nil? || Regexp.last_match(2).nil? || @year.nil? || @month.nil? || @day.nil?
          log_unprocessable_line(line)
          next
        end
      rescue
        log_unprocessable_line(line)
        next
      end
    end
  end

  ##
  # Process and create message entries for speech actions.
  def process_speech(line)
    if line.match(/^(\d\d):(\d\d) <.(.*?)> (.*)/)

      new_message = Message.new
      nick = get_nick_with_just_name(Regexp.last_match(3))

      new_message.nick = nick
      new_message.message = Regexp.last_match(4)

      record_time(Time.utc(@year, @month, @day, Regexp.last_match(1), Regexp.last_match(2)), new_message)
      new_message.action = Action::SPEECH

      new_message.save
    end
  end

  ##
  # Process and create message entries for emote actions.
  def process_emote(line)
    if line.match(/^(\d\d):(\d\d)  \* ([\w\d]*?) (.*)/)
      nick = get_nick_with_just_name(Regexp.last_match(3))

      if nick
        message = Message.new
        message.nick = nick
        message.message = Regexp.last_match(4)
        record_time(Time.utc(@year, @month, @day, Regexp.last_match(1), Regexp.last_match(2)), message)
        message.action = Action::EMOTE

        message.save

        return true
      end
    end

    false
  end

  ##
  # Process and creates message records of system events.
  #
  # This includes items such as joins, quits, kicks, bans, etc.
  def process_system_message(line)
    user_match = line.match(/^(\d\d):(\d\d) -!- (.*?) \[(.*?)@(.*?)\]/)

    unless user_match

      if process_nick_change(line)
      else
        log_unprocessable_line(line)
      end

      return
    end

    hour = Regexp.last_match(1)
    minute = Regexp.last_match(2)
    nick = get_nick_with_name_and_hostname(Regexp.last_match(3), Regexp.last_match(4), Regexp.last_match(5))

    return if process_join(line, nick, hour, minute)

    return if process_quit(line, nick, hour, minute)

    log_unprocessable_line(line)
  end

  ##
  # Searches all known nicks for those with the given name
  def get_nick_with_just_name(name)
    already_existing_nicks = Nick.where(name: name)
    new_nick = Nick.new

    if already_existing_nicks.count > 0
      new_nick = already_existing_nicks.first
    else
      new_nick.name = name

      new_nick.save
    end

    new_nick
  end

  ##
  # Searches all know name and hostname combinations to find the matching nick
  def get_nick_with_name_and_hostname(name, username, hostname)
    already_existing_nicks = Nick.where(name: name)
    new_nick = Nick.new

    if already_existing_nicks.count > 0
      new_nick = already_existing_nicks.first
    else
      new_nick.name = name
      new_nick.username = username

      existing_hostnames = Hostname.where(domain_name: hostname)
      new_hostname = Hostname.new

      # Should only ever have 0 or 1 hostnames with the given domain_name
      new_hostname = existing_hostnames.first if existing_hostnames.count > 0

      new_hostname.domain_name = hostname
      unless new_nick.hostnames.include? new_hostname
        new_nick.hostnames = new_nick.hostnames << new_hostname
      end

      new_nick.save
    end

    new_nick
  end

  ##
  # Processes and creates a user quit message
  #
  # Returns: +true+ if the line is a quit message +false+ otherwise.
  def process_quit(line, nick, hour, minute)
    if line.match(/^\d\d:\d\d -!- .* has quit \[/)
      quit_message = Message.new
      quit_message.nick = nick
      record_time(Time.utc(@year, @month, @day, hour, minute), quit_message)
      quit_message.action = Action::QUIT
      quit_message.save

      return true
    end

    false
  end

  def record_time(message_time, message)
    message.said_at = message_time
    message.hour = message_time.strftime('%H').to_i
    message.minute = message_time.strftime('%M').to_i
  end

  ##
  # Process and create a user join message entry
  #
  # Returns: +true+ if the line is a join message +false+ otherwise.
  def process_join(line, nick, hour, minute)
    if line.match(/^\d\d:\d\d -!- .* has joined /)
      join_message = Message.new
      join_message.nick = nick
      record_time(Time.utc(@year, @month, @day, hour, minute), join_message)
      join_message.action = Action::JOIN
      join_message.save

      return true
    end

    false
  end

  ##
  # Logs any line that cannot be processed
  def log_unprocessable_line(line)
    unprocessable_line_filename = Rails.root.join('log', 'unprocessable_lines.txt')
    File.open(unprocessable_line_filename, 'a') do |file|
      file.write("#{line}")
    end
  end

  def process_nick_change(line)
    if line.match(/^(\d\d):(\d\d) -!- (.*) is now known as (.*)/)
      old_nick = Nick.where(name: Regexp.last_match(3)).first
      if old_nick.nil?
        nick = Nick.new
        nick.name = Regexp.last_match(3)
        nick.save
      end

      new_nick = Nick.where(name: Regexp.last_match(4)).first
      if new_nick.nil?
        nick = Nick.new
        nick.name = Regexp.last_match(4)
        nick.save
      end

      return true
    end

    false
  end
end
