json.extract! author_list, :id, :partcode, :dept, :custcode, :turns, :seq, :priority, :created_at, :updated_at
json.url author_list_url(author_list, format: :json)
