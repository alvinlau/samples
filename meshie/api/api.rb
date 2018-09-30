module Meshie
  class API < Grape::API
    format :json

    helpers do
      def topics
        Padrino.config.mongo[:topics]
      end

      def items
        Padrino.config.mongo[:items]
      end
    end


    resource :debug do
      get :topics do topics.find.to_a end
      get :items do items.find.to_a end
      get :cookies do cookies end
    end



    resource :topics do
      desc 'show a topic'
      route_param :name do
        get do
          topics.find({name: params[:name]}).first
        end
      end


      desc 'make a new draft'
      get do
        uuid = SecureRandom.urlsafe_base64
        result = topics.insert_one({uuid: uuid, links: [], notes: [], widgets: []})
        # TODO: create token for user
        (result.n > 0) ? {uuid: uuid} : {error: 'could not insert'}
      end


      desc 'publish a draft'
      params do
        requires :name, type: String
        requires :uuid, type: String
      end
      post :publish do
        # check the topic name availability
        results = topics.find({name: params[:name]})
        return {error: 'topic name already exists'} if results.to_a.size > 0

        # just set the name of the topic to indicate it is published
        topics.update_one({uuid: params[:uuid]}, {'$set' => {name: params[:name]}} )
        {success: 'published topic', name: params[:name]}
      end


      desc 'update whole topic'
      params do
        requires :name, type: String
        requires :uuid, type: String
      end
      put ':uuid' do
        # just update the required fields for now
      end


      desc 'update topic field'
      patch 'uuid' do
        # create topic class method to sanitize input
      end


      # desc 'request token for a topic'
      # params { requires :visage_id , type: Integer, desc: 'requester id' }
      # route_param :id do
      #   get :token do
      #     # generate token for topic id => visage id
      #   end
      # end
    end



    resource :items do
      desc 'get item'
      route_param :uuid do
        get do
          items.find({uuid: params[:uuid]}).first
        end
      end


      desc 'add link to a topic'
      params do
        requires :url, type: String, desc: 'the url'
        requires :item_name, type: String
        requires :topic_id, type: String
      end
      post :link do
        uuid = SecureRandom.urlsafe_base64
        # TODO: fetch the url and get some meta data
        # try to request the url and use the title as name
        item_name = params[:item_name] || 'new link'
        link_obj = {uuid: uuid, url: params[:url], name: item_name,
                    type: 'link', topic_id: params[:topic_id]}

        items.insert_one(link_obj)
        result = topics.update_one({uuid: params[:topic_id]}, {'$push' => {links: link_obj}})
        (result.modified_count > 0) ? {uuid: uuid} : {error: 'could not insert'}
      end


      desc 'edit item'
      params do
        requires :item_type, type: String
        requires :item_name, type: String
      end
      put ':uuid' do
        results = items.find({uuid: params[:uuid]})
        return {error: 'could not find item'} if results.to_a.size < 1

        item = results.first

        # TODO: helper classes for each type
        case :item_type
        when 'link'
          item.merge({url: params[:url], name: params[:item_name], url_type: params[:url_type]})
          items.update_one({uuid: params[:uuid]})
        when 'note'
        when 'gear'
        when 'label'
        end
      end


      desc 'remove item'
      delete ':uuid' do
        results = items.find({uuid: params[:uuid]})
        return {error: 'could not find item'} if results.to_a.size < 1

        item = results.first
        # TODO: copy it to a 'deleted item' collection or something

        topics.update_one({uuid: item[:topic_id]}, {'$pull' => {links: {uuid: params[:uuid]}}})
      end
    end
  end
end
