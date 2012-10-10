require "sinatra/base"

IMAGES = [
  { title: "Utopia"     , url: "http://fantasyartdesign.com/free-wallpapers/imgs/mid/68landscapes04-m241.jpg" },
  { title: "Alaska"     , url: "http://www.davidsfotos.com/LANDSCAPESpage_files/LANDSCAPES2.jpg" },
  { title: "The Unknown", url: "http://www.beautifullife.info/wp-content/uploads/2010/12/31/the-unknown.jpg" },
]

class App < Sinatra::Base

  enable :sessions

  before /images/ do
    @message = "You're viewing an image."
  end

  before do
    @user = "Jose Mota"
    @height = session[:height]
    puts "==> Entering request"
  end

  after do
    puts "<== Leaving request"
  end

  get "/sessions/new" do
    erb :"sessions/new"
  end

  post "/sessions" do
    session[:height] = params[:height]
  end

  get "/images" do
    @images = IMAGES
    erb :images
  end

  get "/images/:index" do |index|
    index = index.to_i
    @image = IMAGES[index]

    haml :"images/show", layout: true
  end

  get "/" do
    erb :hello, layout: true
  end

  post "/" do
    "Hello World via POST!"
  end

  put "/" do
    "Hello World via PUT!"
  end

  delete "/" do
    "Goodbye World via DELETE!"
  end

  get "/hello/:first_name/?:last_name?" do |first,last|
    "Hello #{first} #{last}"
  end
end
