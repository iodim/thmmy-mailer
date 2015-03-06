module ThmmyNotifier
	class WrongCredentials < StandardError
	end

	class TimeoutError < Timeout::Error
	end

	class NetworkUnreachable < Errno::ENETUNREACH
	end
end