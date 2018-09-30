require 'addressable/uri'

Cardinold::App.controllers :card, :provides => [:html] do

  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # layout :card

  get '/' do
    # render 'view'
    render 'new'
  end


  get '/:id' do
    puts "fetching #{params[:id]}"
    @card_id = params[:id]

    # get it from mongo
    client = Mongo::Client.new('mongodb://127.0.0.1:27017/test')
    cards = client[:cards]
    card = cards.find({uuid: @card_id}).first
    # puts card

    @title = card[:title]
    @previews = card[:urls]
    render 'view'
  end


  post '/' do
    @title = params[:title]
    urls = [params[:url1], params[:url2], params[:url3]]

    puts urls

    @previews = []

    saved_urls = []

    client = Mongo::Client.new('mongodb://127.0.0.1:27017/test')
    contents = client[:previews]

    urls.compact.reject(&:empty?).each do |url|
      puts uri
      result = Cardinold::URL.parse(url)
      next if !result

      site = result[:site]

      html = Oga.parse_html result[:html]
      title = html.at_css('title')

      host = Addressable::URI.parse(url).host

      # puts "title = #{title}"
      url_hash = { title: title.text, site: site, url: "#{url}"}
      saved_urls << url_hash
      @previews << url_hash
    end

    # save it in mongo
    cards = client[:cards]
    @uuid = SecureRandom.uuid

    result = cards.insert_one( {uuid: @uuid, title: @title, urls: saved_urls } )
    puts result.n > 0 ? "Saved card" : "count not save card"
    puts result.inserted_id

    # render 'view'
    redirect "card/#{@uuid}"
  end


  # add link
  patch '/:id' do

  end


  get '/addlinks' do
    # return input field and div for next add link call
  end


  # generate preview
  get '/preview' do
    url = params[:url]
    req = Typhoeus::Request.new url
    res = req.run

    render res.headers.title
  end

  get :new do
    render 'new'
  end

  get :preview do
    render :slim, 'p link preview text'
  end

end
