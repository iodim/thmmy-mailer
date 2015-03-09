class CreateCourses < ActiveRecord::Migration
	def self.up
		create_table :courses do |t|
			t.string :title
			t.integer :ethmmy_id
		end

		add_index :courses, :ethmmy_id
	end

	def self.down
		drop_table :courses
	end
end