#!/usr/bin/ruby

require 'mechanize'

module Helpers
	Announcement = Struct.new(:title, :date, :author, :body)

	def ethmmy_sanitize(announcement)
		arr = announcement.search('p')
		title = arr[0].text.scan(/[^\r\n\t]/).join.lstrip
		date = arr[1].search('b').text.scan(/[^\r\n\t]/).join.lstrip
		author = arr[1].search('i').text.scan(/[^\r\n\t]/).join.lstrip

		announcement.search('p.listLabel').remove
		announcement.search('p > b').remove
		announcement.search('p > i').remove
		body = announcement.to_html(:encoding => 'UTF-8').gsub('&amp;', '&')

		return Announcement.new(title, date, author, body)
	end

	def psyche_sanitize(announcement)
		
	end
end