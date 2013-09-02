class LogFileProcessor
  @day = 1
  @month = "jan"
  @year = 2013

  def processLogFile(filenameOfLogFile)

    IO.foreach(filenameOfLogFile) do |line|
    
      if line.match(/^$/)
        next
      end
    
      if line.match(/^---/) then
        line.match(/(\w\w\w) (\d\d)(?: \d\d:\d\d:\d\d)? (\d\d\d\d)/)
        @day = $2
        @month = $1
        @year = $3
        next
      end
      
      if line.match(/^\d\d:\d\d -!-/) then
        process_system_message(line)
        next
      end
      
      if line.match(/^\d\d:\d\d  \*/)
        process_emote(line)
        next
      end
    
      line.match(/^(\d\d):(\d\d) <.(.*?)> (.*)/)
      newMessage = Message.new

      newMessage.nick = $3
      newMessage.message = $4
      newMessage.said_at = Time.utc(@year, @month, @day, $1, $2)
      newMessage.action = Action::SPEECH
    
      newMessage.save
    
    end
  end
  
  def process_emote(line)
    if line.match(/^(\d\d):(\d\d)  \* ([\w\d]*?) (.*)/)
      nick = get_nick_with_just_name($3)

      if nick
        message = Message.new
        message.nick = nick.name
        message.message = $4
        message.said_at = Time.utc(@year, @month, @day, $1, $2)
        message.action = Action::EMOTE

        message.save
      
        return true
      end
    end

    return false
  end
  
  def process_system_message(line)
    user_match = line.match(/^(\d\d):(\d\d) -!- (.*?) \[(.*?)@(.*?)\]/)
    if !user_match
      return
    end
    
    nick = get_nick_with_name_and_hostname($3, $4, $5)
    
    hour = $1
    minute = $2
    
    if process_join(line, nick.name, hour, minute)
      return
    end
    
    if process_quit(line, nick.name, hour, minute)
      return
    end
  end
  
  def get_nick_with_just_name(name)
    already_existing_nicks = Nick.where("name = ?", name)

    Rails.logger.debug("#{Time.now}nickname search #{name}")

    return find_or_create_nick(already_existing_nicks, name)      
  end
  
  def get_nick_with_name_and_hostname(name, username, hostname)
    already_existing_nicks = Nick.where("name = ? AND hostname = ?", name, hostname)

    new_nick = find_or_create_nick(already_existing_nicks, name)
    new_nick.username = username
    new_nick.hostname = hostname
    new_nick.save
    
    return new_nick
  end
  
  def find_or_create_nick(already_existing_nicks, name)
    new_nick = Nick.new

    if already_existing_nicks.count > 0
      new_nick = already_existing_nicks.first
    else
      new_nick.name = name
    
      new_nick.save
    end
    
    return new_nick
  end
  
  ## 
  # Processes and creates a user quit message
  # 
  # Returns: +true+ if the line is a quit message +false+ otherwise.
  def process_quit(line, nick, hour, minute)
    if line.match(/^\d\d:\d\d -!- .* has quit \[/)
      quit_message = Message.new
      quit_message.nick = nick
      quit_message.said_at = Time.utc(@year, @month, @day, hour, minute)
      quit_message.action = Action::QUIT
      quit_message.save
      
      return true
    end
    
    return false
  end

  ##
  # Process and create a join message entry
  # 
  # Returns: +true+ if the line is a join message +false+ otherwise.
  def process_join(line, nick, hour, minute)
    if line.match(/^\d\d:\d\d -!- .* has joined /)
      join_message = Message.new
      join_message.nick = nick
      join_message.said_at = Time.utc(@year, @month, @day, hour, minute)
      join_message.action = Action::JOIN
      join_message.save
      
      return true
    end
    
    return false
  end
  
end