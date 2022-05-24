$bot.message(start_with: PREFIX + 'spotify') do |event|
    args = event.content.split(" ")
    return unless args.shift == PREFIX + "spotify"
    # Assign values from args and event
    command = ["track", "info", "suggest", "genres", "gamut"].include?(args.first) ? args.shift : nil
    # Case command
    begin
        event.respond case command
            when "track"; spotify_track(args.join(" "))
            when "info"; spotify_track_info(args.join(" "))
            when "suggest"; spotify_suggest(args)
            when "genres"; spotify_genres()
            when "gamut"; spotify_gamut()
            else; spotify_track(args.join(" "))
        end
       # event.message.delete
    rescue => e
        puts e.message
        puts e.backtrace
        event.respond format_error("Invalid command!")
    end
end

def spotify_track(query = '')
    return format_usage("spotify track <query>") if query == ''
    return build_spotify_track_message(query)
end

def spotify_track_info(query = '')
    return format_usage("spotify info <query>") if query == ''
    return build_spotify_info_message(query)
end

def spotify_suggest(genres = [])
    return format_usage("spotify suggest <genres>") if genres == []
    return build_spotify_suggestions(genres)
end

def spotify_genres()
    return build_spotify_genres()
end

def spotify_gamut()
    return EMOTION_GAMUT.join(" ")
end