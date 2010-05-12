require 'net/http'
require 'uri'

class Omgl
  def omg_connect
    @stranger_a = {"id" => get_stranger, "name" => "Stranger A"}
    puts @stranger_a["id"]
    sleep 1

    @stranger_b = {"id" => get_stranger, "name" => "Stranger B"}
    puts @stranger_b["id"]

    listen_server
  end

  private

  def format_id(string)
    string[1..-2]
  end

  def get_stranger
    url = URI.parse('http://omegle.com/start')
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http| http.request(req)}
    format_id(res.body)
  end

  def listen_server
    while true
      res = Net::HTTP.post_form(URI.parse('http://omegle.com/events'), {"id" => @stranger_a["id"]})
      res = res.body.split(/"(.*?)"/)
      print_conversation(res, @stranger_a, @stranger_b)

      res = Net::HTTP.post_form(URI.parse('http://omegle.com/events'), {"id" => @stranger_b["id"]})
      res = res.body.split(/"(.*?)"/)
      print_conversation(res, @stranger_b, @stranger_a)
    end
  end

  def print_conversation(message, from, to)
      message.each_index do |i|
        if message[i] == "waiting"
          puts "Waiting for #{from["name"]}..."
        elsif message[i] == 'strangerDisconnected'
          puts "#{from["name"]} Disconnected!"
          sleep 5
          omg_connect
        elsif message[i] == "connected"
          puts "Found #{from["name"]}"
        elsif message[i] == "typing"
          Net::HTTP.post_form(URI.parse('http://omegle.com/typing'), {"id" => to["id"]})
        elsif message[i] == "gotMessage"
          talk(to["id"], message[i + 2])
          puts "#{from["name"]}: #{message[i + 2]}"
        end
      end
  end

  def talk(id, msg)
    msgReq = Net::HTTP.post_form(URI.parse('http://omegle.com/send'), {"msg" => msg, "id" => id})
  end
end

Omgl.new.omg_connect
