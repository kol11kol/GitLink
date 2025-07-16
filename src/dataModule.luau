local dataModule = {}
function dataModule.getData(p, KEY)
	return p:GetSetting(KEY)
end
function dataModule.newData(p, NAME, VALUE)
	p:SetSetting(NAME, VALUE)
end
function dataModule.createRepoData(url, key, user, p)
	local function repoName()
		for i, str in pairs(string.split(url, "/")) do
			if str == user then
				return string.split(url, "/")[i + 1]
			end
		end
	end	
	local repository = {
		["NAME"] = repoName(),
		["USER"] = user,
		["URL"] = ("https://api.github.com/repos/"..user.."/"..repoName()),
		["KEY"] = key
	}
	local repositories = {}
	local function len(tab)
		local sum = 0
		for _, v in pairs(tab) do
			sum = sum + 1
		end
		return sum
	end
	if not (dataModule.getData(p, "REPOSITORIES") == nil) then
		repositories = dataModule.getData(p, "REPOSITORIES")
	end
	local code
	if not (repositories == nil) then
		if len(repositories) > 0 then
			if repositories[repository.NAME] then
				code = "fail"
				warn("Repository was created! ".."Edit "..repository.NAME.." to change settings!")
			elseif not repositories[repository.NAME] then
				code = "success"
				repositories[tostring(repository.NAME)] = repository
				dataModule.newData(p, "REPOSITORIES", repositories)
			end
		elseif len(repositories) == 0 then
			code = "success"
			print("Creating first repository!")
			repositories[tostring(repository.NAME)] = repository
			dataModule.newData(p, "REPOSITORIES", repositories)
		end
	end	
	return {code = code, name = repository.NAME}
end
function dataModule.updateRepoData(url, key, user, p)
	local function repoName()
		for i, str in pairs(string.split(url, "/")) do
			if str == user then
				return string.split(url, "/")[i + 1]
			end
		end
	end	
	local repository = {
		["NAME"] = repoName(),
		["USER"] = user,
		["URL"] = ("https://api.github.com/repos/"..user.."/"..repoName()),
		["KEY"] = key
	}
	local repositories = {}
	local function len(tab)
		local sum = 0
		for _, v in pairs(tab) do
			sum = sum + 1
		end
		return sum
	end
	if not (dataModule.getData(p, "REPOSITORIES") == nil) then
		repositories = dataModule.getData(p, "REPOSITORIES")
	end
	local code
	if not (repositories == nil) then
		code = "success"
		repositories[tostring(repository.NAME)] = repository
		dataModule.newData(p, "REPOSITORIES", repositories)
	end	
	return {code = code, name = repository.NAME}
end
function dataModule.addDefaultRepository(p, repositoryName)
	local function len(tab)
		local sum = 0
		for _, v in pairs(tab) do
			sum = sum + 1
		end
		return sum
	end
	local repositories = {}
	if not (dataModule.getData(p, "DEFAULTREPOSITORIES") == nil) then
		repositories = dataModule.getData(p, "DEFAULTREPOSITORIES")
	end
	local repository = {
		name = repositoryName,
		place = game.PlaceId
	}
	if not (repositories == nil) then
		if len(repositories) > 0 then
			if repositories[repository.name] then
				warn("Repository is already set to defualt! ".."Edit "..repository.name.." to change it!")
			elseif not repositories[repository.name] then
				repositories[tostring(repository.name)] = repository
				dataModule.newData(p, "DEFAULTREPOSITORIES", repositories)
			end
		elseif len(repositories) == 0 then
			repositories[tostring(repository.name)] = repository
			dataModule.newData(p, "DEFAULTREPOSITORIES", repositories)
		end
	end
end
function dataModule.removeDefaultRepository(p, repositoryName)
	local function len(tab)
		local sum = 0
		for _, v in pairs(tab) do
			sum = sum + 1
		end
		return sum
	end
	local repositories = {}
	if dataModule.getData(p, "DEFAULTREPOSITORIES") then
		if len(dataModule.getData(p, "DEFAULTREPOSITORIES")) > 0 then
			repositories = dataModule.getData(p, "DEFAULTREPOSITORIES")
			if len(repositories[repositoryName]) > 0 then
				for name, data in pairs(repositories) do
					if name == repositoryName then
						repositories[repositoryName] = nil
					end
				end
				dataModule.newData(p, "DEFAULTREPOSITORIES", repositories)
			end
		end
	end
end
function dataModule.removeRepositoryData(p, repositoryName)
	local function len(tab)
		local sum = 0
		for _, v in pairs(tab) do
			sum = sum + 1
		end
		return sum
	end
	local repositories = {}
	if dataModule.getData(p, "REPOSITORIES") then
		if len(dataModule.getData(p, "REPOSITORIES")) > 0 then
			repositories = dataModule.getData(p, "REPOSITORIES")
			if len(repositories[repositoryName]) > 0 then
				for name, data in pairs(repositories) do
					if name == repositoryName then
						repositories[repositoryName] = nil
					end
				end
				dataModule.newData(p, "REPOSITORIES", repositories)
			end
		end
	end
end
return dataModule
--[[

		Saved repository data formant:
		
		local repo = {
			name = repositoryName
			url = repositoryURL
			token = repositoryToken
			user = GithubName
		}

]]