module ThmmyNotifier	
	class Announcement < ActiveRecord::Base
		validates :uhash, uniqueness: true
		belongs_to :course
		after_save :on_new_announcement, unless: :initialising?

		def self.initialising=(state)
			@@initialising = state
		end

		protected
			def on_new_announcement
				puts self.uhash
			end

			def initialising?
				@@initialising
			end
	end
end