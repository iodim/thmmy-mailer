class CreateAnnouncements < ActiveRecord::Migration
	def self.up
		create_table :announcements do |t|
			t.string :title
			t.string :author
			t.string :body
			t.string :uhash
			t.belongs_to :courses
			t.timestamps null: false
		end

		add_index :announcements, :courses_id
	end

	def self.down
		drop_table :announcements
	end
end		