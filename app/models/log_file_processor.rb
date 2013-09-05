require 'active_support/core_ext'

class LogFileProcessor
  @day = 1
  @month = "jan"
  @year = 2013

  ##
  # Process the provided log file and add the values into the database
  def process_log_file(filename_of_log_file)

    IO.foreach(filename_of_log_file) do |line|
    
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

      new_message = Message.new

      new_message.nick = $3
      new_message.message = $4
      new_message.said_at = Time.utc(@year, @month, @day, $1, $2)
      new_message.action = Action::SPEECH
    
      if(is_message_already_logged(new_message.nick, new_message.message, new_message.said_at))
        next
      end

      new_message.save
    
    end
  end
  
  ##
  # Process and create message entries for emote actions.
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
  
  ##
  # Process and creates message records of system events.
  #
  # This includes items such as joins, quits, kicks, bans, etc.
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

  ##
  # Searches all known nicks for those with the given name
  def get_nick_with_just_name(name)
    already_existing_nicks = Nick.where(:name => name)

    Rails.logger.debug("#{Time.now}nickname search #{name}")

    return find_or_create_nick(already_existing_nicks, name)      
  end
  
  ##
  # Searches all know name and hostname combinations to find the matching nick
  def get_nick_with_name_and_hostname(name, username, hostname)
    already_existing_nicks = Nick.where(:name =>  name, :hostname => hostname)

    new_nick = find_or_create_nick(already_existing_nicks, name)
    new_nick.username = username
    new_nick.hostname = hostname
    new_nick.save
    
    return new_nick
  end
  
  ##
  # Finds the the first nick in the provided list or creates a new one if no match is found.
  #
  # Returns: A nick object with the name property of the provided name
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
  # Process and create a user join message entry
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
  
  ##
  # Check that the message has not already been saved to the database.
  #
  # Where someone rapidly repeats the same thing this will result in that being flattened into one item. 
  # I cannot think of a nicer way to avoid duplicates from multiple logfiles 
  def is_message_already_logged(name, message_body, said_at)
    found_messages = Message.where(:nick => name, :message => message_body, :said_at => said_at.change(:sec => 0)..said_at.change(:sec => 59))
    
    return found_messages.count > 0
  end
  
end