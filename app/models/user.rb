class User < ApplicationRecord
  self.table_name = "fs_call_lists_users"
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable
end
