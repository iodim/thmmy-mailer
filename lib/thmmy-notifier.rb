$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'yaml'
require 'logger'
require 'sqlite3'
require 'ruby-prof'
require 'mechanize'
require 'digest/md5'
require 'active_record'
require 'thread_safe'
require 'thmmy-notifier/db'
require 'thmmy-notifier/ethmmy'
require 'thmmy-notifier/psyche'
require 'thmmy-notifier/helpers'
require 'thmmy-notifier/exceptions'
require 'thmmy-notifier/course'
require 'thmmy-notifier/announcement'


module ThmmyNotifier

	def self.init_ethmmy_agent(username = 'guest', password = 'guest')
		@@username = username
		@@password = password

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

	def self.populate_announcements_table(username, password)
		threads = []
		mutex = Mutex.new
		announcement_hash = {}

		Announcement.initialising = true

		@courses_cache.values.each_slice(@courses_cache.length / 10) do |chunk|
			threads << Thread.new do
				Ethmmy.login(username, password) do |ethmmy_agent|
					chunk.each do |ethmmy_id|
						announcement_hash[ethmmy_id] = []
						ethmmy_agent.get_all_announcements_by(ethmmy_id).each do |announcement|
							mutex.synchronize  do 
								announcement_hash[ethmmy_id] << announcement
							end
						end
					end
				end
			end
		end

		threads.each do |thread|
			thread.join
		end

		ActiveRecord::Base.transaction do 
			announcement_hash.each do |ethmmy_id, announcements|
				announcements.each do |announcement|
					Announcement.create(announcement.merge(courses_id: @courses_cache.values.index(ethmmy_id) +1))
				end
			end
		end

		Announcement.initialising = false
	end

	def self.check_for_new_announcements(username, password)
		threads = []
		mutex = Mutex.new
		announcement_hash = {}

		Announcement.initialising = false

		@courses_cache.values.each_slice(@courses_cache.length / 10) do |chunk|
			threads << Thread.new do
				Ethmmy.login(username, password) do |ethmmy_agent|
					chunk.each do |ethmmy_id|
						mutex.synchronize  do 
							announcement_hash[ethmmy_id] = ethmmy_agent.get_latest_announcement_by(ethmmy_id)
						end
					end
				end
			end
		end

		threads.each do |thread|
			thread.join
		end

		ActiveRecord::Base.transaction do 
			announcement_hash.each do |ethmmy_id, announcement|
				unless announcement.nil?
					Announcement.create(announcement.merge(courses_id: @courses_cache.values.index(ethmmy_id) +1))
				end
			end
		end

	end
end