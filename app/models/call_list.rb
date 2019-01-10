class CallList < ApplicationRecord
  has_many :call_days, inverse_of: :call_list, :dependent => :destroy
  accepts_nested_attributes_for :call_days, reject_if: proc { |attributes| attributes['callday'].blank? }

  def self.import(file)
    CSV.foreach(file.path, headers:true, :encoding => 'windows-1251:utf-8') do |row|
      CallList.create! row.to_hash
    end
  end

  def user_is_isr(c)
    isr_match = false
    c.call_days.each do |d|
      if d.isr == current_user.email.upcase
        isr_match = true
      end
    end
    isr_match
  end

end
