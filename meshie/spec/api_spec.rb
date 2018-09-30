require 'airborne'

describe 'topics' do
  it 'should create and publish topics' do
    # create new topic and get the id
    get 'localhost:9000/api/topics'
    expect(topic_id = json_body[:uuid]).not_to be nil

    # generate a topic name and call publish
    topic_name = "test_topic#{SecureRandom.urlsafe_base64}"
    post 'localhost:9000/api/topics/publish', {name: topic_name, uuid: topic_id.to_s}
    # puts "publish result: #{json_body}"
    expect(json_body[:success]).not_to be(nil), 'cannot publish topic'
    expect(json_body[:name]).to eq(topic_name), 'published topic name does not match'

    # try showing the topic
    get "localhost:9000/api/topics/#{topic_name}"
    expect(json_body).not_to be(nil)
    expect(json_body[:name]).to eq(topic_name), "published topic name does not match"
  end

  it 'should create edit and delete link items' do
    # find existing topic to edit
    get 'localhost:9000/api/topics/sample'
    expect(topic_id = json_body[:uuid]).not_to be(nil), 'cannot find sample topic'

    # ----- add item --------
    post 'localhost:9000/api/items/link',
      {item_name: "test url #{SecureRandom.urlsafe_base64}", topic_id: topic_id, url: 'testurl.com'}
    expect(item_id = json_body[:uuid]).not_to be(nil), 'cannot add link item'

    # get the item again to check
    get "localhost:9000/api/items/#{item_id}"
    item_obj = json_body
    item_obj.delete :_id
    expect(json_body[:uuid]).not_to be(nil), 'cannot find link item after add'

    # get the topic again and check its items
    get 'localhost:9000/api/topics/sample'
    match_link = json_body[:links].find { |link| item_obj == link }
    expect(match_link).not_to be(nil), 'cannot find added item in sample topic'

    # ------ edit item -------
    put "localhost:9000/api/items/#{item_id}", {item_type: 'link', item_name: 'test url edited'}

    # get the item again to check
    get "localhost:9000/api/items/#{item_id}"
    item_obj = json_body
    item_obj.delete :_id
    expect(json_body[:uuid]).not_to be(nil), 'cannot find link item after edit'

    # get the topic again and check its items
    get 'localhost:9000/api/topics/sample'
    match_link = json_body[:links].find { |link| item_obj == link }
    expect(match_link).not_to be(nil),  'cannot find edited item in sample topic'

    # ------- remove item ------------
    delete "localhost:9000/api/items/#{item_id}"
    get "localhost:9000/api/items/#{item_id}"
    expect(json_body[:uuid]).to eq(item_id)

    get 'localhost:9000/api/topics/sample'
    match_link = json_body[:links].find { |link| item_obj == link }
    expect(match_link).to be(nil), 'removed link still exists in topic'
  end

end
