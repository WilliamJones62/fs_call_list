class CallList < ApplicationRecord

  def self.import(file)
    CSV.foreach(file.path, headers:true) do |row|
      CallList.create! row.to_hash
    end
  end

end
