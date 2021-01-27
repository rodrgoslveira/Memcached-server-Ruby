module Response
  STORED = "STORED\r\n"
  NOT_STORED = "NOT_STORED\r\n"
  NOT_FOUND = "NOT_FOUND\r\n"
  EXISTS = "EXISTS\r\n"
  END_VALUE = "END\r\n"

  def generate_retrival_response(items, gets_command)
    data_response = ""
    if gets_command
      items.each{ |e|
        data_response << "VALUE #{e.key} #{e.flags} #{e.bytes} #{e.cas}\r\n"
        data_response << "#{e.data}\r\n" #data_block
      }
    else
      items.each{ |e|
        data_response << "VALUE #{e.key} #{e.flags} #{e.bytes}\r\n"
        data_response << "#{e.data}\r\n" #data_block
      }
    end
    data_response << "#{END_VALUE}"
  end
end
