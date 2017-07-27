require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'pry-byebug'
require_relative 'parser'

DB = SQLite3::Database.new(File.join(File.dirname(__FILE__), 'db/jukebox.sqlite'))

get '/' do
  @cur = DB.execute(%(SELECT * FROM artists
    JOIN albums ON albums.artist_id = artists.id
    GROUP BY artists.name
    ORDER BY artists.name)).map do |arr|
    { id: arr[0], name: arr[1] }
  end
  erb :home
end

get '/artists/:artist_id' do
  @artists_cur = DB.execute(%(
    SELECT artists.name, albums.title, genres.name, albums.id, artists.id
    FROM albums
    JOIN artists ON artists.id = albums.artist_id
    JOIN tracks ON tracks.album_id = albums.id
    JOIN genres ON genres.id = tracks.genre_id
    WHERE artists.id = #{params[:artist_id]}
    GROUP BY albums.title)).map do |arr|
    { artists_name: arr[0],
      albums_title: arr[1],
      genres_name: arr[2],
      album_id: arr[3],
      artist_id: arr[4] }
  end
  erb :artist
end

get '/albums/:album_id' do
  @albums_cur = DB.execute(%(SELECT tracks.name, albums.title, tracks.id
    FROM tracks
    JOIN albums ON tracks.album_id = albums.id
    WHERE album_id = #{params[:album_id]})).map do |arr|
    { tracks_name: arr[0], albums_title: arr[1], tracks_id: arr[2] }
  end
  erb :album
end

get '/tracks/:track_id' do
  @tracks_cur = DB.execute(%(SELECT tracks.name, artists.name, albums.title
    FROM tracks
    JOIN albums ON albums.id = tracks.album_id
    JOIN artists ON artists.id = albums.artist_id
    WHERE tracks.id = #{params[:track_id]})).map do |arr|
    { tracks_name: arr[0], artists_name: arr[1], albums_title: arr[2] }
  end
  @parser = Parser.new(@tracks_cur[0])
  erb :track
end

not_found do
  status 404
  erb :noooo
end
