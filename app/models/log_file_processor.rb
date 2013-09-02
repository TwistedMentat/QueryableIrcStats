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
        processSystemMessage(line)
        next
      end
    
      line.match(/^(\d\d):(\d\d) <.(.*)> (.*)/)
      newMessage = Message.new

      newMessage.nick = $3
      newMessage.message = $4
      newMessage.said_at = Time.utc(@year, @month, @day, $1, $2)
      newMessage.action = Action::SPEECH
    
      newMessage.save
    
    end
  end
  
  def processSystemMessage(line)
    user_match = line.match(/^(\d\d):(\d\d) -!- (.*?) \[(.*?)@(.*?)\]/)
    if !user_match
      return
    end
    
    hour = $1
    minute = $2
    
    new_nick = Nick.new
    already_existing_nicks = Nick.where("name = ? AND hostname = ?", $3, $5)

    if already_existing_nicks.count > 0
      new_nick = already_existing_nicks.first
    else
      new_nick.name = $3
      new_nick.username = $4
      new_nick.hostname = $5
    
      new_nick.save
    end
    
    if process_join(line, new_nick.name, hour, minute)
      return
    end
    
    if process_quit(line, new_nick.name, hour, minute)
      return
    end
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