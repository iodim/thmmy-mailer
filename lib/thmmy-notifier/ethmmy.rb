module ThmmyNotifier
	class Ethmmy
		attr_reader :subscriptions, :username

		def initialize(username = 'guest', password = 'guest')
			@username = username
			@base_url = 'https://alexander.ee.auth.gr:8443/eTHMMY/'
			login_slug = 'loginAction.do'

			#cert_store = OpenSSL::X509::Store.new
			#cert_store.set_default_paths
			#cert_store.add_file File.expand_path('./cacert.pem')

			@agent = Mechanize.new { |agent|
				  #agent.user_agent_alias = 'Mac Safari'
				  #agent.cert_store = cert_store
				  #agent.ssl_version='SSLv3'
				  agent.verify_mode= OpenSSL::SSL::VERIFY_NONE
				  #agent.agent.http.ca_file = File.expand_path('./cacert.pem')
			}

			begin
				tries ||= 3
				login = @agent.post(
					@base_url + login_slug, {
					:username => username,
					:password => password
					}
				)

				raise LoginAsGuest, "Warning: logging in as guest, access limited" if @username == 'guest'

				if login.search("//a[starts-with(@href, \"/eTHMMY/logout.do\")]").empty?
					raise WrongCredentials, 'Incorrent username and/or password'					
				end
			rescue LoginAsGuest => e
				puts e
			rescue WrongCredentials => e
				puts e
				exit
			rescue TimeoutError => e
				print e 
				if tries > 1
					puts '. Retrying'
					sleep(1)
					tries -= 1
					retry
				end
				puts '. Exiting'
				exit
			rescue NetworkUnreachable => e
				print e 
				if tries > 1
					puts '. Retrying'
					sleep(1)
					tries -= 1
					retry
				end
				puts '. Exiting'
				exit
			end

			@subscriptions = get_subscriptions
		end

		def self.login(username = 'guest', password = 'guest')
			ethmmy_instance = Ethmmy.new(username, password)
			yield ethmmy_instance
			ethmmy_instance.logout
		end

		def logout
			logout_slug = 'logout.do'
			@agent.get @base_url + logout_slug
		end

		def get_courses_by_semester(semester)
			courses = {}
			year = (semester + 1) / 2
			season = semester - (year - 1)*2
			courses_slug = 'cms.course.data.do?method=jsplist&PRMID='
			
			if @username == 'guest'
				anchor_child = 1
			else
				anchor_child = 3
			end

			@agent.get(@base_url + courses_slug + year.to_s) do |year_page|
				year_page.search("table.etDivTitleCont")[season - 1].parent.search('table').each do |entry|
					course = entry.search('p.listLabel')
					title = course.search("a:nth-child(#{anchor_child})").text
					ethmmy_id = course.search("a:nth-child(#{anchor_child}) @href").text.match(/\d+$/).to_s.to_i
					courses[title] = ethmmy_id unless title.empty?
				end
			end
			return courses
		end

		def get_courses_by_year(year)
			return get_courses_by_semester(year*2-1).merge courses_by_semester(year*2)
		end

		def get_all_courses
			courses = {}
			1.upto 10 do |semester|
				courses.merge! get_courses_by_semester(semester)
			end
			return courses
		end

		def get_subscriptions
			subscriptions = []
			home_slug = 'home.do'
			unless @username == 'guest'
				@agent.get(@base_url + home_slug) do |home_page|
					sidebar = home_page.search(".//img[@src=\"images/books.gif\"]")
					sidebar.each do |course|
						subscriptions << course.parent['href'].match(/\d+$/).to_s.to_i
					end
				end
			end
			return subscriptions
		end

		def get_latest_announcement_by(id)
			announcement = nil
			subscribe_to id unless @subscriptions.include? id
			course_login_to id
			announcements_slug = 'cms.announcement.data.do?method=jsplist&PRMID='
			@agent.get(@base_url + announcements_slug + id.to_s) do |announcements_page|
				announcement = announcements_page.search('p.listLabel').first
			end
			unsuscribe_from id unless @subscriptions.include? id
			return sanitize(announcement.parent, id) unless announcement.nil?
		end

		def get_all_announcements_by(id)
			announcements = []
			subscribe_to id unless @subscriptions.include? id
			course_login_to id
			announcements_slug = 'cms.announcement.data.do?method=jsplist&PRMID='
			@agent.get(@base_url + announcements_slug + id.to_s) do |announcements_page|
				announcements_board = announcements_page.search('p.listLabel').map(&:parent)
				unless announcements_board.nil?
					announcements_board.each do |announcement|
						announcements << sanitize(announcement, id)
					end
				end
			end
			unsuscribe_from id unless @subscriptions.include? id
			return announcements
		end

		def get_all_subscription_announcements
			announcements = {}
			@subscriptions.each do |id|
				p id
				announcements[id] = get_all_announcements_by id
			end
			return announcements
		end

		def subscribe_to(id)
			subscribe_slug = 'cms.course.data.do?method=jspregister&PRMID='
			@agent.get(@base_url + subscribe_slug + id.to_s)
		end

		def subscribe_to!(id)
			subscribe_to id
			@subscriptions << id
			#@subscriptions.sort!
		end

		def unsuscribe_from(id)
			unsuscribe_slug = 'cms.course.data.do?method=jspunregister&PRMID='
			@agent.get(@base_url + unsuscribe_slug + id.to_s)
		end

		def unsubscribe_from!(id)
			unsubscribe_from id
			@subscriptions.delete id
		end

		def course_login_to(id)
			course_login_slug = 'cms.course.login.do?method=execute&PRMID='
			@agent.get(@base_url + course_login_slug + id.to_s)
		end

		def sanitize(announcement, id)
			arr = announcement.search('p')
			title = arr[0].text.scan(/[^\r\n\t]/).join.lstrip
			date = arr[1].search('b').text.scan(/[^\r\n\t]/).join.lstrip
			author = arr[1].search('i').text.scan(/[^\r\n\t]/).join.lstrip

			announcement.search('p.listLabel').remove
			announcement.search('p > b').remove
			announcement.search('p > i').remove
			body = announcement.to_html(:encoding => 'UTF-8').gsub('&amp;', '&')

			pp Course.create(title: 'sae',ethmmy_id: id)

			return Announcement.create(
				title: title,
				author: author,
				body: body,
				courses_id: Course.where(ethmmy_id: id)[0].id,
				uhash: Digest::MD5.hexdigest(title+date+author)
			)
		end
	end
end