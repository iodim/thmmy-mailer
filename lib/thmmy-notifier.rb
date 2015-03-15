$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'yaml'
require 'logger'
require 'sqlite3'
require 'ruby-prof'
require 'mechanize'
require 'digest/md5'
require 'active_record'
require 'thmmy-notifier/db'
require 'thmmy-notifier/ethmmy'
require 'thmmy-notifier/psyche'
require 'thmmy-notifier/helpers'
require 'thmmy-notifier/exceptions'
require 'thmmy-notifier/course'
require 'thmmy-notifier/announcement'


module ThmmyNotifier

	def self.init_ethmmy_agent(username = 'guest', password = 'guest')
		@ethmmy_agent = Ethmmy.new(username, password)
		@ethmmy_agent.login
	end

	def self.init_psyche_agent

	end

	def self.kill_ethmmy_agent
		@ethmmy_agent.logout
	end

	def self.build_courses_cache
		@courses_cache = @ethmmy_agent.get_all_courses
	end

	def self.populate_courses_table
		ActiveRecord::Base.transaction do
			@courses_cache.each do |title, ethmmy_id|
				Course.create(title: title, ethmmy_id: ethmmy_id)
			end
		end
	end

	def self.populate_announcements_table
		ActiveRecord::Base.transaction do
			@courses_cache.values.each do |ethmmy_id|
				@ethmmy_agent.get_all_announcements_by(ethmmy_id).each do |announcement|
					Announcement.create(announcement.merge(courses_id: @courses_cache.values.index(ethmmy_id) + 1))
				end
			end
		end
	end

	def self.check_for_new_announcements
		@courses_cache.values.each do |ethmmy_id|
				#Announcement.create(announcement.merge(courses_id: @courses_cache.values.index(ethmmy_id) + 1))
				pp @ethmmy_agent.get_latest_announcement_by(ethmmy_id)
		end
	end
end