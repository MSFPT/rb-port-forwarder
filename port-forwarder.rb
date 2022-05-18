#!/usr/bin/env ruby
# https://github.com/msfpt/rb-port-forwarder

require 'socket'
require 'resolv'

def server(lport, rhost, rport) # local-port , replace-host , replace-port
  begin
    rport_server = TCPServer.new('127.0.0.1', rport)
    while true 

      rport_client = rport_server.accept
      lport_server = TCPSocket.new(rhost, lport)
      Thread.new { forward(rport_client, lport_server) }
      Thread.new { forward(lport_server, rport_client) }

      chost  = rport_client.peeraddr[3]
      clport = rport_client.addr[1]
      crhost = lport_server.peeraddr[3]
      crport = lport_server.peeraddr[1]
      puts "\n  [*] #{chost}:#{clport} --> #{crhost}:#{crport}" # comment this line to stop verbose output
    end
  rescue Errno::EACCES => error
    puts " [-] Failed to listen on #{rhost}:#{rport} (reason: Permission denied)\n\n"
    rport_server.close if rport_server
    lport_server.close if lport_server
  rescue Exception => error
    puts "Error(server): #{error}"
    rport_server.close if rport_server
    lport_server.close if lport_server
  end  
end

def forward(src, dst)
  while true 
    begin
      data = src.recv(1024)
      dst.send(data, 0) unless data.empty?
    rescue Exception => error
      puts "Error(forward): #{error}"
      src.close
      dst.close
    end
  end
end

def get_ip
  # return (Socket.ip_address_list.detect{|intf| intf.ipv4_private?}).ip_address
  return '127.0.0.1'
end

def check_accuracy_ip(ip) # Check Accuracy IP
  return ip =~ Resolv::IPv4::Regex ? true : false
end

if (ARGV[0] == '--help') || (ARGV[0] == '-h')
  puts "
Args:
  --help or -h # show this message
  --local-port or -lp # required
  --forward or -f # optional

Usage: 
  `ruby port-forwarder.rb -lp [local-port] -f [forward-host]:[forward-port]`

Example:
  `ruby port-forwarder.rb -lp 80 -f "+get_ip+":6060`
  
Tip: 
  if you forward it to an IP address you are not connected to,
  it will connect, but it will only work when you connect to it.

GitHub: 
  https://github.com/msfpt/rb-port-forwarder
 \n"
  exit true
end

if (ARGV.include? '--local-port') || (ARGV.include? '-lp')
  lport = ARGV[ARGV.index((ARGV.include? '--local-port') ? '--local-port' : '-lp')+1];
  if (lport.to_i > 0) && (lport.to_i < 65535)
    lport = lport.to_i
  else
    puts "Usage: `ruby port-forwarder.rb --help`"
    puts "Note: [local-port] must be a number between 1 and 65535."
    exit false
  end
else
  puts "Usage: `ruby port-forwarder.rb --help`"
  puts "Note: Use of [local-port] is required"
  exit false
end

def get_rport(rhost)
  begin
    while true
      puts " please enter [forward-port]"
      printf "  ↪ #{rhost}:"
      rport = STDIN.gets.to_i
      if (rport > 0) && (rport < 65535) ;break
      else puts "\n   Note: [forward-port] must be a number between 1 and 65535.\n\n"
      end
    end
    return rport
  rescue Interrupt => error  
    puts "\n"
    exit true
  end
end

if (ARGV.include? '--forward') || (ARGV.include? '-f')
  replace_data = ARGV[ARGV.index((ARGV.include? '--forward') ? '--forward' : '-f')+1];
  begin
    replace_data = replace_data.split ':'
    if (replace_data.count > 0) && (replace_data.count < 3)
      rhost , rport = replace_data

      if !check_accuracy_ip(rhost)
        rhost = get_ip
      end

      if (rport.to_i > 0) && (rport.to_i < 65535) ;lport = lport.to_i
      else rport = get_rport(rhost.to_s)
      end
    else
      puts "Usage: `ruby port-forwarder.rb --help`"
      puts "Note: *forward* argument takes up to 2 values."
      exit false
    end
  rescue NoMethodError => error
    puts "Usage: `ruby port-forwarder.rb --help`"
    puts "Note: [forward-data] should not be empty!"
    exit false
  rescue => error
    puts error
  end
else
  rhost = get_ip
  rport= get_rport(rhost.to_s)
end

begin
  puts "\n [✔] Forwarded from http://127.0.0.1:#{lport.to_s} to http://#{rhost.to_s}:#{rport.to_s}"
  puts "\n [+] Press 'Ctrl + C' or exit safely (won't terminate your netcat session) "
  server(lport, rhost, rport)
rescue => error
  puts error
end