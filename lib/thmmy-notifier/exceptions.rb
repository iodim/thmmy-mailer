module ThmmyNotifier
	class LoginAsGuest < StandardError
	end

	class WrongCredentials < StandardError
	end

	class TimeoutError < Errno::ETIMEDOUT
	end

	class NetworkUnreachable < Errno::ENETUNREACH
	end
end


			# begin

			# rescue LoginAsGuest => e
			# 	puts e
			# rescue WrongCredentials => e
			# 	puts e
			# 	exit
			# rescue TimeoutError => e
			# 	print e 
			# 	if tries > 1
			# 		puts '. Retrying'
			# 		sleep(1)
			# 		tries -= 1
			# 		retry
			# 	end
			# 	puts '. Exiting'
			# 	exit
			# rescue NetworkUnreachable => e
			# 	print e 
			# 	if tries > 1
			# 		puts '. Retrying'
			# 		sleep(1)
			# 		tries -= 1
			# 		retry
			# 	end
			# 	puts '. Exiting'
			# 	exit
			# end