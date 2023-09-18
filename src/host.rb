def is_valid_host?(host)
  return false if host.nil?
  return false if host.empty?
  return false if host == '127.0.0.1'
  return false if host == '0.0.0.0'
  return true if host =~ /^(chn|rus|ger|bra|chl|usa|kor|tur|twn|irn|arg|per|sau|zaf|sgp|ind|aus)\d*\.ddnet.org$/
  return true if host == 'fokkonaut.de'
  return true if host == 'tw.fokkonaut.de'
  return false if host == '149.202.127.134' # TODO: remove this hack
  disallow_regex = ENV['BANNED_HOST']
  unless disallow_regex.nil?
    return false if host.match(disallow_regex)
  end
  # TODO: caching
  servers = JSON.parse(URI.open("https://master1.ddnet.org/ddnet/15/servers.json").read)
  in_master = servers["servers"].map {|s| s["addresses"] }.to_s.include? host
  return false unless in_master

  block = /\d{,2}|1\d{2}|2[0-4]\d|25[0-5]/
  ipv4_regex = /\A#{block}\.#{block}\.#{block}\.#{block}\z/
  !host.match(ipv4_regex).nil?
end

# puts is_valid_host?("fokkonaut.de") == true
# puts is_valid_host?("fokkonaut.deg") == false
# puts is_valid_host?("ger1.ddnet.org") == true
# puts is_valid_host?("ger10.ddnet.org") == true
# puts is_valid_host?("ger10.ddnet.organized") == false
# puts is_valid_host?("germany.ddnet.org") == false
# 
# puts is_valid_host?("1.1.1.1") == true
# puts is_valid_host?("900.900.900.900") == false
# puts is_valid_host?("2.2") == false
# puts is_valid_host?("usa.gov") == false
# 
# puts is_valid_host?("localhost") == false
# puts is_valid_host?("127.0.0.1") == false
# 
# puts is_valid_host?("8.8.8.8") == true
# ENV['BANNED_HOST'] = '(8\.8\.8\.8|1\.1\.1\.1)'
# puts is_valid_host?("8.8.8.8") == false
# puts is_valid_host?("1.1.1.1") == false
