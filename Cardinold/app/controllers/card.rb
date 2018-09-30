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
    render 'view'
  end

  post '/' do
    title = params[:title]
    urls = [params[:url1], params[:url2], params[:url3]]

    puts urls

    @previews = []

    urls.compact.reject(&:empty?).each do |url|
      # puts uri
      html = Typhoeus.get(url, followlocation: true).body
      # puts Oga.parse_html html
      title = Oga.parse_html(html).at_css('title')
      # puts "title = #{title}"
      @previews << {title: title.text, url: "http://#{url}"}

    end

    render 'created'
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
