USAGE_FILES = {
    "spotify"   => "./usage-spotify.txt",
}

$bot.message(start_with: PREFIX + 'help') do |event|
    args = event.content.split(" ")
    return unless args.shift == PREFIX + 'help'
    # Assign values from args and event
    topic = args.shift
    # Case command
    begin
        if topic == nil
            for topic, path in USAGE_FILES do
                message = File.readlines(path).map { |line| line.chomp.gsub('~', PREFIX) }
                event.respond format_help(message.join("\n"))
            end
        elsif USAGE_FILES.key?(topic)
            message = File.readlines(USAGE_FILES[topic]).map { |line| line.chomp.gsub('~', PREFIX) }
            event.respond format_help(message.join("\n"))
        else
            event.respond format_usage("help <#{USAGE_FILES.keys.join("|")}>")
        end
    rescue => e
        puts e.message
        puts e.backtrace
        event.respond format_error("Invalid command!")
    end
end