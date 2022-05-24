BOT_PATH = './lib/bot.rb'
KEYS = ["./discord_token", "./discord_client_id", "./spotify_client_id", "./spotify_client_secret"]

def check_keys
    for key in KEYS do
        unless File.file?(key)
            puts "Missing #{key}..."
            return false
        end
    end
    return true
end

task :run do
    puts system("ruby #{BOT_PATH}") if check_keys
end

task :bg do
    system("ruby #{BOT_PATH} &") if check_keys
end