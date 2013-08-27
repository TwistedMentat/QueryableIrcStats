class LogFileProcessor

  def processLogFile(filenameOfLogFile)
    day = 1
    month = "jan"
    year = 2013

    IO.foreach(filenameOfLogFile) do |line|
    
      if line.match(/^$/)
        next
      end
    
      if line.match(/^---/) then
        line.match(/(\w\w\w) (\d\d)(?: \d\d:\d\d:\d\d)? (\d\d\d\d)/)
        day = $2
        month = $1
        year = $3
        next
      end
      
      if line.match(/^\d\d:\d\d -!-/) then
        processSystemMessage(line)
      end
    
      line.match(/^(\d\d):(\d\d) <.(.*)> (.*)/)
      newMessage = Message.new

      newMessage.nick = $3
      newMessage.message = $4
      newMessage.said_at = Time.utc(year, month, day, $1, $2)
    
      newMessage.save
    
    end
  end
  
  def processSystemMessage(line)
    line.match(/^\d\d:\d\d -!- (.*) \[(.*)@(.*)\]/)
    
    newNick = Nick.new
    
    newNick.name = $1
    newNick.username = $2
    newNick.hostname = $3
    
    newNick.save
  end
end