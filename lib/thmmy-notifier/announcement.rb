module ThmmyNotifier	
	class Announcement < ActiveRecord::Base
		validates :uhash, uniqueness: true
		belongs_to :course
	end
end