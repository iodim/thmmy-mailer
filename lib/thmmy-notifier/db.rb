module ThmmyNotifier
	ActiveRecord::Base.establish_connection(YAML.load_file((File.dirname(__FILE__) + '/../../config/databases.yml'))['development'])

	class Course < ActiveRecord::Base
		has_many :announcements
	end

	class Announcement < ActiveRecord::Base
		belongs_to :course
	end
end