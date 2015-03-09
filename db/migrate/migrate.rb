class CreateCourses < ActiveRecord::Migration
	def self.up
		create_table :courses do |t|
			t.string :title
			t.integer :ethmmy_id
		end
	end

	def self.down
		drop_table :courses
	end
end

class CreateAnnouncements < ActiveRecord::Migration
	def self.up
		create_table :announcements do |t|
				t.string :title
				t.string :author
				t.string :body
				t.timestamps null: false
		end

		add_foreign_key :announcements, :courses, column: :ethmmy_id
	end
end		
