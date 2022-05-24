EMOTION_GAMUT = [
    ":sleeping:",
    ":pensive:",
    ":neutral_face:",
    ":slight_smile:",
    ":grin:",
    ":smile:",
    ":laughing:",
    ":face_with_spiral_eyes:",
    ":star_struck:",
    ":exploding_head:",
]

def auth_spotify
    begin
        RSpotify::authenticate(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET)
    rescue
        return "``Could not authenticate to Spotify API``"
    end
end

def get_track(str)
    # Attempt to grab track ID from a URL string
    track_id = (str + "?")[/track\/(.*?)\?/, 1]
    return RSpotify::Track.find(track_id) unless track_id == nil
    return RSpotify::Track.search(str, limit: 1).first
end

def build_spotify_info_message(str)
    auth_spotify()
    begin
        track = get_track(str)
        return [
            build_track_card(track),
            "```",
            "acousticness=#{track.audio_features.acousticness}",
            "danceability=#{track.audio_features.danceability}",
            "duration_ms=#{track.audio_features.duration_ms}",
            "energy=#{track.audio_features.energy}",
            "instrumentalness=#{track.audio_features.instrumentalness}",
            "key=#{track.audio_features.key}",
            "liveness=#{track.audio_features.liveness}",
            "loudness=#{track.audio_features.loudness}",
            "mode=#{track.audio_features.mode}",
            "popularity=#{track.popularity}",
            "speechiness=#{track.audio_features.speechiness}",
            "tempo=#{track.audio_features.tempo}",
            "time_signature=#{track.audio_features.time_signature}",
            "valence=#{track.audio_features.valence}",
            "```",
        ].compact.join("\n")
    rescue => e
        # Bad track request
        # puts e.message
        return "``Could not identify Spotify track for search term \"#{str}\"``"
    end
end

def get_energy_emoji(level)
    return EMOTION_GAMUT[(level * EMOTION_GAMUT.length).floor]
end

def build_track_card(track)
    track_name, artist_name = track.name, track.artists.first.name
    genres = (track.album.genres + track.artists.first.genres).uniq
    genres = genres.empty? ? "" : "(#{genres.join("/")})"
    url = "https://open.spotify.com/track/" + track.uri.gsub("spotify:track:", "")
    # Set emojis
    explicit = track.explicit ? ":underage:" : nil
    energy = get_energy_emoji(track.audio_features.energy)
    emojis = [explicit, energy].compact.join(" ")
    # Return message
    return "#{emojis} **#{artist_name} - #{track_name}** #{genres}\n#{url}"
end

def build_spotify_track_message(str)
    auth_spotify
    # Find track using track_id
    begin
        # Get track information
        track = get_track(str)
        return "``Could not identify Spotify track for search term \"#{str}\"``" if track == nil
        return build_track_card(track)
    rescue => e
        # Bad track request
        # puts e.message
        return "``Could not identify Spotify track for search term \"#{str}\"``"
    end
end

def build_spotify_genres
    # Authenticate
    begin
        RSpotify::authenticate(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET)
        genres = RSpotify::Recommendations.available_genre_seeds
        return ["```", genres, "```"].compact.join("\n")
    rescue
        return "``Could not authenticate to Spotify API``"
    end
end

def build_spotify_suggestions(genres)
    # Authenticate
    begin
        output = []
        output << "``Searching for a few suggestions using the genres: [#{genres.join("/")}]...``"
        RSpotify::authenticate(SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET)
        tracks = RSpotify::Recommendations.generate(limit: 3, seed_genres: genres).tracks
        output << tracks.map { |track| build_track_card(track) }
        return output.flatten.join("\n")
    rescue => e
        puts e.message
        return "``Could not authenticate to Spotify API``"
    end
end 
