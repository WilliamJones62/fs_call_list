class CallDay < ApplicationRecord
  belongs_to :call_list, :foreign_key => "call_list_id"

  def self.import(file)
    CSV.foreach(file.path, headers:true, :encoding => 'windows-1251:utf-8') do |row|
      CallDay.create! row.to_hash
    end
  end
end
