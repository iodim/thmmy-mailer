#!/usr/bin/ruby

# Individual announcements
# http://psyche.ee.auth.gr/index.php?view=article&news&id=223&tmpl=component

# All announcements
# http://psyche.ee.auth.gr/index.php?option=com_content&view=category&id=5&Itemid=6&lang=el&limit=0
module ThmmyNotifier
	class Psyche

		def initialize()
		@base_url = 'http://psyche.ee.auth.gr/index.php?'

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
		end

		def self.login()
			psyche_instance = Psyche.new()
			yield psyche_instance
		end
	end
end