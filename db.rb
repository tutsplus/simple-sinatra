env = ENV["RACK_ENV"] || "development"
url = "sqlite://#{Dir.pwd}/db/#{env}.sqlite3"
DataMapper.setup :default, url

class Image
  include DataMapper::Resource

  property :id          , Serial
  property :title       , String
  property :url         , String , length: 0..250
  property :description , Text
end

DataMapper.finalize
DataMapper.auto_upgrade!
