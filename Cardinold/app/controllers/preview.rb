Cardinold::App.controllers :preview, :provides => [:html] do

  get '/:uuid' do
    puts "fetching preview for #{params[:uuid]}"
    uuid = params[:uuid]

    # get it from mongo
    client = Mongo::Client.new('mongodb://127.0.0.1:27017/test')
    previews = client[:previews]
    card = previews.find({uuid: uuid}).first
    card[:content] # it's just html text
  end

end
