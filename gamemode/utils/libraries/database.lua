require("mysqloo")

module("database", package.seeall)

local logger = log.Create("database")
local DATABASE = CustomMetaTable("DatabaseConnection")

function New(host, username, password, database, port)
	local cr = async.Assert()

	local connection = mysqloo.connect(host, username, password, database, port or 3306)
	local instance = setmetatable({
		Host = host,
		Username = username,
		Database = database,
		Port = port or 3306,
		Name = string.format("%s@%s:%s", database, host, port or 3306),
		SuppressState = false,
		-- 1 minute, 10 minutes, 30 minutes, 1 hour
		RateMetrics = util.RateCounter(60, 600, 1800, 3600),
		TimeMetrics = util.RateCounter(60, 600, 1800, 3600)
	}, DATABASE)

	connection.onConnected = function()
		local ok, err = connection:setCharacterSet("utf8mb4")

		if ok then
			logger:Info(instance:Log("Connected to server"))

			async.Handle(cr, instance)
		else
			instance:Error("Unable to set character encoding: " .. err)
		end
	end

	connection.onConnectionFailed = function(_, err) instance:Error(err) end
	connection:connect()

	instance.Connection = connection

	return coroutine.yield()
end

function DATABASE:Log(str, ...)
	return "[%s] %s", self.Name, string.format(str, ...)
end

function DATABASE:LogQuery(query, str)
	return "[%s] [Query: %p] %s", self.Name, query, str
end

function DATABASE:Error(err)
	error(string.format("[%s]: %s", self.Name, err))
end

function DATABASE:Escape(str)
	return self.Connection:escape(str)
end

function DATABASE:StartQuery(query, suppress)
	local cr = async.Assert()
	local startTime = SysTime()

	local function finish()
		local time = (SysTime() - startTime) * 1000

		self.TimeMetrics:Add(time)

		logger:Debug(self:LogQuery(query, string.format("Query finished after %i ms", time)))
	end

	if suppress then
		logger:Debug(self:LogQuery(query, "SUPPRESSING ERRORS"))
	end

	query.onSuccess = function(_, data)
		finish()

		if suppress then
			async.Handle(cr, true, data, query.lastInsert and tonumber(query:lastInsert()))
		else
			async.Handle(cr, data, query.lastInsert and tonumber(query:lastInsert()))
		end
	end

	query.onError = function(_, err)
		finish()

		if suppress then
			async.Handle(cr, false, err)
		else
			self:Error(err)
		end
	end

	query:start()
end

function DATABASE:Query(str, data)
	data = data or {}

	local args = {}

	local function parseArg(key, arg)
		if isnumber(arg) then
			table.insert(args, {"setNumber", arg})
		elseif isstring(arg) then
			table.insert(args, {"setString", arg})
		elseif isbool(arg) then
			table.insert(args, {"setBoolean", arg})
		elseif arg == NULL then
			table.insert(args, {"setNull"})
		else
			error(string.format("bad key :%s to Query (number/string/bool/NULL expected, got %s)", key, type(arg)), 5)
		end
	end

	local query = self.Connection:prepare(string.gsub(str, ":(%a+)", function(key)
		local arg = data[key]

		if arg == nil then
			error("Missing argument: " .. key, 4)
		elseif istable(arg) then
			if not table.IsSequential(arg) then
				error("Table argument isnt sequential", 4)
			end

			for _, v in pairs(arg) do
				parseArg(key, v)
			end

			return string.format("(%s)", string.rep("?", #arg, ", "))
		else
			parseArg(key, arg)
		end

		return "?"
	end))

	for k, arg in ipairs(args) do
		query[arg[1]](query, k, arg[2])
	end

	if self.Transaction then
		table.insert(self.Transaction, query)

		logger:Info(self:Log(str))

		return
	end

	logger:Info(self:LogQuery(query, str))

	self.RateMetrics:Add()
	self:StartQuery(query, self.SuppressState)
	self.SuppressState = false

	return coroutine.yield()
end

function DATABASE:RawQuery(str)
	local query = self.Connection:query(str)

	if self.Transaction then
		table.insert(self.Transaction, query)

		logger:Info(self:Log(str))

		return
	end

	logger:Info(self:LogQuery(query, str))

	self.RateMetrics:Add()
	self:StartQuery(query, self.SuppressState)
	self.SuppressState = false

	return coroutine.yield()
end

function DATABASE:RunMigrations(path)
	logger:Info("Running migrations from `%s`", path)

	self:Query("CREATE TABLE IF NOT EXISTS `migrations` (`Name` VARCHAR(256) NOT NULL UNIQUE)")

	local files = file.Find(path .. "*.lua", "LUA", "nameasc")
	local ranMigrations = table.Lookup(table.Map(self:Query("SELECT * FROM `migrations` ORDER BY `Name`"), function(val) return val.Name end))

	for _, filePath in pairs(files) do
		local fileName = string.FileName(filePath)

		logger:Debug("Found migration file `%s`", fileName)

		if not ranMigrations[fileName] then
			logger:Info("Running migration file `%s`", fileName)

			include(path .. filePath)(self)

			self:Query("INSERT INTO `migrations` (`Name`) VALUES (:name)", {
				name = fileName
			})
		end
	end

	logger:Info("Checked %s migration files", #files)
end

function DATABASE:Suppress()
	self.SuppressState = true
end

function DATABASE:Begin()
	if self.Transaction then
		logger:Warning(self:Log("Started a new transaction while another is queued, this probably broke something fierce"))
	end

	self.Transaction = {}

	logger:Info(self:Log("TRANSACTION START"))
end

function DATABASE:Commit()
	if not self.Transaction then
		logger:Warning(self:Log("Tried to commit a transaction but we don't have one queued up?"))

		return
	end

	if #self.Transaction < 1 then
		logger:Warning(self:Log("Skipping empty transaction"))

		self.Transaction = nil

		return
	end

	local transaction = self.Connection:createTransaction()

	logger:Info(self:Log("TRANSACTION COMMIT: %p", transaction))

	for _, query in ipairs(self.Transaction) do
		transaction:addQuery(query)
	end

	self.RateMetrics:Add(#self.Transaction)

	self:StartQuery(transaction, self.SuppressState)

	self.Transaction = nil
	self.SuppressState = nil

	return coroutine.yield()
end
