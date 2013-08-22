class LogFileProcessor

  def processLogFile(filenameOfLogFile)
    arrayOfLines = Array.new
    
    IO.foreach(filenameOfLogFile) do |line|
      arrayOfLines << line
    end
    
    day = 1
    month = "jan"
    year = 2013

    arrayOfLines.each do |l|
    
      if l.match(/^$/)
        next
      end
    
      if l.match(/^---/) then
        l.match(/(\w\w\w) (\d\d)(?: \d\d:\d\d:\d\d)? (\d\d\d\d)/)
        day = $2
        month = $1
        year = $3
        next
      end
      
      if l.match(/^\d\d:\d\d -!-/) then
        next        
      end
    
      l.match(/^(\d\d):(\d\d) <.(.*)> (.*)/)
      newMessage = Message.new

      newMessage.nick = $3
      newMessage.message = $4
      newMessage.said_at = Time.utc(year, month, day, $1, $2)
    
      newMessage.save
    
    end
  end
  
end