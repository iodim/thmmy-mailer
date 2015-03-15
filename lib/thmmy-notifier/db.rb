module ThmmyNotifier
	ActiveRecord::Base.establish_connection(YAML.load_file((File.dirname(__FILE__) + '/../../config/database.yml'))['development'])
	ActiveRecord::Base.logger = Logger.new(STDOUT)
	#ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/../../log/db.log')

	if db = ActiveRecord::Base.connection
		db.execute "PRAGMA page_size = 4096"
		db.execute "PRAGMA cache_size = 2000"
		db.execute "PRAGMA locking_mode = EXCLUSIVE"
		db.execute "PRAGMA synchronous = OFF"
		db.execute "PRAGMA journal_mode = MEMORY"
		db.execute "PRAGMA temp_store = WAL"
	end

end