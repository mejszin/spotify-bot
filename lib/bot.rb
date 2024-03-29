BOT_NAME = '👉👈'
BOT_AVATAR = './data/pleading_face.png'
PREFIX = '.'

require 'bundler'
Bundler.setup(:default, :ci)

require 'rest-client'
require 'discordrb' # https://www.rubydoc.info/gems/discordrb/3.2.1/
require 'rspotify' # https://www.rubydoc.info/github/guilhermesad/rspotify/
require 'json'
require 'faraday'

DISCORD_TOKEN = File.read('./discord_token').chomp
DISCORD_CLIENT_ID = File.read('./discord_client_id').chomp
puts "DISCORD_TOKEN=#{DISCORD_TOKEN}"
puts "DISCORD_CLIENT_ID=#{DISCORD_CLIENT_ID}"
SPOTIFY_CLIENT_ID = File.read('./spotify_client_id').chomp
SPOTIFY_CLIENT_SECRET = File.read('./spotify_client_secret').chomp
puts "SPOTIFY_CLIENT_ID=#{SPOTIFY_CLIENT_ID}"
puts "SPOTIFY_CLIENT_SECRET=#{SPOTIFY_CLIENT_SECRET}"

require './lib/api.rb'

def format_standard(str); return "```\n#{str}\n```"; end
def format_success(str); return "```diff\n+ #{str}\n```"; end
def format_error(str); return "```diff\n- #{str}\n```"; end
def format_usage(str); return "Command usage: ``#{PREFIX}#{str}``"; end
def format_help(str); return "```markdown\n#{str}\n```"; end

$bot = Discordrb::Bot.new(token: DISCORD_TOKEN, client_id: DISCORD_CLIENT_ID)

require './lib/events.rb'
require './lib/help.rb'

$bot.message(start_with: PREFIX + 'init') do |event|
    $bot.profile.username = BOT_NAME
    $bot.profile.avatar = File.open(BOT_AVATAR)
    event.respond format_success('Initialized bot!')
end

$bot.message(start_with: PREFIX + 'test') do |event|
    event.message.user.pm "Test"
end

$bot.message(start_with: PREFIX + 'listen') do |event|
    event.respond format_success('Listening to alerts...')
    last_check = Time.now.to_i
    while true
        alerts = get_alerts()
        puts "(#{alerts.size}) alerts"
        alerts.each do |alert|
            puts [alert["timestamp"], last_check].inspect
            if alert["timestamp"] < last_check - 3600
                if alert.key?("caller")
                    event.respond format_help("Incoming call from '#{alert["caller"]}'...")
                else
                    event.respond format_help(alert.inspect)
                end
            end
        end
        last_check = Time.now.to_i
        sleep(10)
    end
end

# require './lib/slash.rb'

$bot.run
