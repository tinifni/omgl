require 'net/http'
require 'uri'

def fmtId(string)
  return string[1..(string.length - 2)]
end

def listenServer(idA, idB)

  while true
    
    res = Net::HTTP.post_form(URI.parse('http://omegle.com/events'),
                                         {'id'=>idA})

    recA = res.body.split(/"(.*?)"/)

    sleep 1

    res = Net::HTTP.post_form(URI.parse('http://omegle.com/events'),
                                         {'id'=>idB})

    recB = res.body.split(/"(.*?)"/)
    
    recA.each_index {|i|
      if recA[i] == "waiting"
        puts "Waiting for Stranger A..."

      elsif recA[i] == 'strangerDisconnected'
        puts "Stranger A Disconnected!"
        sleep 5
        omgConnect()

      elsif recA[i] == "connected"
        puts "Found Stranger A"

      elsif recA[i] == "typing"
        Net::HTTP.post_form(URI.parse('http://omegle.com/typing'),
                            {'id'=>idA})

      elsif recA[i] == "gotMessage"
        talk idB, recA[i + 2]
        puts "Stranger A: #{recA[i + 2]}"

      end
    }

    recB.each_index {|i|
      if recB[i] == "waiting"
        puts "Waiting for Stranger B..."

      elsif recB[i] == 'strangerDisconnected'
        puts "Stranger B Disconnected!"
        sleep 5
        omgConnect()

      elsif recB[i] == "connected"
        puts "Found Stranger B"

      elsif recB[i] == "typing"
        Net::HTTP.post_form(URI.parse('http://omegle.com/typing'),
                            {'id'=>idB})

      elsif recB[i] == "gotMessage"
        talk idA, recB[i + 2]
        puts "Stranger B: #{recB[i + 2]}"

      end
    }
  end
end

def talk(id, msg)

  msgReq = Net::HTTP.post_form(URI.parse('http://omegle.com/send'),
                     {'msg'=>msg,'id'=>id})

end

def omgConnect()
  url = URI.parse('http://omegle.com/start')
  req = Net::HTTP::Get.new(url.path)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
  idA = fmtId(res.body)

  puts idA
  
  sleep 1

  url = URI.parse('http://omegle.com/start')
  req = Net::HTTP::Get.new(url.path)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
  idB = fmtId(res.body)

  puts idB

  sleep 1

  listenServer idA, idB
end

omgConnect
