require "sinatra/base"

IMAGES = [
  { title: "Utopia"     , url: "/images/0.jpeg" },
  { title: "Alaska"     , url: "/images/1.jpeg" },
  { title: "The Unknown", url: "/images/2.jpeg" },
]

class App < Sinatra::Base
  
  enable :sessions
  disable :show_exceptions
  register Sinatra::Prawn
  register Sinatra::Namespace

  helpers Sinatra::ContentFor
  helpers Sinatra::JSON

  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Admins only!")
        halt 401
      end
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'admin']
    end
  end

  before /images/ do
    @message = "You're viewing an image."
  end

  configure do
    set({ foo: "bar", baz: "foo" })
  end

  not_found do
    haml :"404", layout: true, layout_engine: :erb
  end

  error do
    haml :error, layout: true, layout_engine: :erb
  end

  error 403 do
    haml :"403", layout: true, layout_engine: :erb
  end

  get "/500" do
    raise StandardError, "Intentional blowing up"
  end

  before do
    @user = "Jose Mota"
    @height = session[:height]
    @environment = settings.environment
    @request = request
    @logger = Log4r::Logger["app"]
  end

  after do
    logger = Log4r::Logger["app"]
    logger.info "<== Leaving request"
  end

  get "/sessions/new" do
    erb :"sessions/new"
  end

  post "/sessions" do
    session[:height] = params[:height]
  end

  get "/sample.pdf" do
    attachment
    content_type :pdf
    @message = "Hello from the PDF!"
    prawn :samplepdf
  end

  namespace "/images" do

    get ".json" do
      @images = Image.all
      json @images
    end

    get "/:id.json" do |id|
      @image = Image.get(id)
      json @image
    end

    post ".json" do
      protected!
      @logger.debug params
      @image = Image.create params[:image]
      @logger.debug @image.saved?
      json message: "Image successfully created."
    end
    get do # /images
      @images = Image.all
      haml :"/images/index", layout_engine: :erb
    end

    get "/:id" do |id|
      @image = Image.get(id)
      haml %s(images/show), layout_engine: :erb
    end

    post do
      protected!
      @image = Image.create params[:image]
      redirect "/images"
    end
  end

  get "/images" do
    halt 403 if session[:height].nil?
    @images = IMAGES
    erb :images
  end

  get "/images/:index/download" do |index|
    @image = IMAGES[index.to_i]
    attachment @image[:title]
    send_file "images/#{index}.jpeg"
  end

  get "/images/:index.?:format?" do |index, format|
    index = index.to_i
    @image = IMAGES[index]
    @index = index

    if format == "jpeg"
      content_type :jpeg # image/jpeg
      send_file "images/#{index}.jpeg"
    else
      haml :"images/show", layout: true, layout_engine: :erb
    end
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

# vim: foldmethod=indent
