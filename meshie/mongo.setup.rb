require 'mongo'

client = Mongo::Client.new(['127.0.0.1:27017'], :database => 'local')
# db = client.database
topics = client[:topics]
topics.insert_one({name: 'john', desc: 'happy'})
topics.find.to_a.first
