module ThmmyNotifier
	class Course < ActiveRecord::Base
		validates :ethmmy_id, uniqueness: true
		has_many :announcements
	end
end