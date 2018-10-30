class CallDay < ApplicationRecord
  belongs_to :call_list, :foreign_key => "call_list_id"

  def self.import(file)
    CSV.foreach(file.path, headers:true) do |row|
      CallDay.create! row.to_hash
    end
  end
end
