module ThmmyNotifier
	ActiveRecord::Base.establish_connection(YAML.load_file((File.dirname(__FILE__) + '/../../config/database.yml'))['development'])

	class Course < ActiveRecord::Base
		validates :ethmmy_id, uniqueness: true
		has_many :announcements
	end

	class Announcement < ActiveRecord::Base
		belongs_to :course
	end
end