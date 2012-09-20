require 'open-uri'
require 'nokogiri'
require 'curb'
require 'digest'
require 'twitter'
require 'redis'

uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
URL = 'http://www.kvb-koeln.de/mofis/ticker_details.html'
USER_AGENT = 'Mozilla/5.0 (KVB-Twitter-Ticker-Bot: http://github.com/Holek/kvb-twitter-ticker) @KVBStoerungen'

Twitter.configure do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
  config.oauth_token = ENV['OAUTH_TOKEN']
  config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
end
Twitter.connection_options[:headers][:user_agent] = USER_AGENT

# headers to use:
# User-Agent:
# Referer: http://www.kvb-koeln.de/german/home/mofis.html

# curl http://www.kvb-koeln.de/mofis/ticker_details.html -H 'Referer: http://www.kvb-koeln.de/german/home/mofis.html' -H 'User-Agent: Mozilla/5.0 (KVB-Twitter-Ticker-Bot: http://github.com/Holek/kvb-twitter-ticker) @KVBStoerungen'

def post(text)
  puts text
  Twitter.update(text)
end

while true
  begin
    hash_keys = REDIS.hkeys('texts')
    hashes = []
    http = Curl.get(URL) do |http|
      http.headers['Referer'] = 'http://www.kvb-koeln.de/german/home/mofis.html'
      http.headers['User-Agent'] = USER_AGENT
    end
    body = http.body_str
    doc = Nokogiri::HTML(body)
    texts = doc.xpath('//body/div/table/tr[3]/td/text()').map(&:text)
    texts.each do |text|
      hash = Digest::SHA256.hexdigest(text)
      return if REDIS.hmget('texts', hash) == '1'

      text = text.strip
      if text.length <= 140
        post(text)
      else
        done = false
        text_part = nil
        text_parts = []
        i = 1
        prev_index = 0
        until done
          length = (text_part || text).length
          if length > 130
            index = text.rindex(' ', prev_index + 130)
            text_parts << text[prev_index, index - prev_index].strip
            text_part = text[index, text.length]
            prev_index = index
          else
            text_parts << (text_part = text[prev_index, text.length].strip)
            done = true
          end
          i = i+1
        end
        i=0
        text_parts.reverse.each do |text|
          i= i+1
          post(text + " (#{i+1}/#{text_parts.size})")
        end
      end
      REDIS.hmset('texts', hash, '1')
      hashes << hash
      sleep 5
    end
    REDIS.hdel('texts', *(hash_keys - hashes))
  rescue
  end

  sleep 120
end
