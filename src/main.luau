local remoteReporCreator : ModuleScript = require(script.Parent.repositories.remoteRepository)
local localRepoModule : ModuleScript = require(script.Parent.repositories.localRepo)
local loginMod : ModuleScript = require(script.loginPageModule)
local dataMod : ModuleScript = require(script.dataModule)
local pageModule : ModuleScript = require(script.pageModule)
local creatorMod : ModuleScript = require(script.creatorModule)
local http : ModuleScript = require(script.Parent.http.httpModule)
local toolbar : PluginToolbar = plugin:CreateToolbar("GitLink")
local button : PluginToolbarButton = toolbar:CreateButton("1", "Open GitLink", "rbxassetid://99707391500270", "Open Gitlink")
local widgetInfo : DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo.new( --size should be minimum 1/4 of screen size
	Enum.InitialDockState.Float, -- Widget will be initialized in floating panel
	true, -- Widget will be initially enabled
	true, -- Don't override the previous enabled state
	960, -- Default width of the floating window
	540, -- Default height of the floating window
	480, -- Minimum width of the floating window (optional)
	270, -- Minimum height of the floating window (optional)
	3840,
	2160
)
local httpService = game:GetService("HttpService")
local remoteRepo : remoteReporCreator.remoteRepository
local localRepo
local local_remote_Files = {}
local index : number = 1
local filesStatus : boolean = true
local currentFile : string
pageModule.clonePages()
local main: DockWidgetPluginGui
local id : number = 0
local currentPage : Frame
local repositories = {}
local function len(tab)
	local sum : number = 0
	for _, v in pairs(tab) do
		sum = sum + 1
	end
	return sum
end
function getAllFiles()
	filesStatus = false
	local function createUI()
		for _, button in pairs(pageModule.currentPages.repository.list.ScrollingFrame:GetChildren()) do
			if button:IsA("TextButton") and not (button.Name == "add") then
				button.Parent = nil
			end
		end
		if #remoteRepo.files > 0 then
			for _, file in pairs(remoteRepo.files) do
				if not table.find(local_remote_Files, string.split(httpService:JSONDecode(http.GET({Url = remoteRepo.url, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user}).Body).name, ".")[1], 1) then
					local clone : TextButton = script.uiElements.file:Clone()
					clone.Parent = pageModule.currentPages.repository.list.ScrollingFrame
					clone.Text = (string.split(httpService:JSONDecode(http.GET({Url = remoteRepo.url, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user}).Body).name, ".")[1].." [Remote]")
				end	
			end
		end
		if #localRepo.scriptDocuments > 0 then
			for _, file in pairs(localRepo.scriptDocuments) do
				if not table.find(local_remote_Files, file.Name, 1) and not remoteRepo.files[file.Name] then
					local clone : TextButton = script.uiElements.file:Clone()
					clone.Parent = pageModule.currentPages.repository.list.ScrollingFrame
					clone.Text = (file.Name.." [Local]")
				end	
			end
		end
		if #local_remote_Files then
			for _, file in pairs(local_remote_Files) do
				local clone : TextButton = script.uiElements.file:Clone()
				clone.Parent = pageModule.currentPages.repository.list.ScrollingFrame
				if file.path then
					clone.Text = string.split(httpService:JSONDecode(http.GET({Url = remoteRepo.url, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user}).Body).name, ".")[1]
				else
					clone.Text = file
				end
			end
		end	
	end
	table.clear(remoteRepo.files)
	table.clear(local_remote_Files)
	local function deep_search(tbl)
		for key, value in pairs(tbl) do
			if typeof(value) == "table" then
				if value.type == "blob" then
					if #remoteRepo.files == 0 then
						if string.split(httpService:JSONDecode(http.GET({Url = remoteRepo.url, path = ("/contents/" .. value.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user}).Body).name, ".")[2] == "luau" then
							table.insert(remoteRepo.files, value)
						end	
					elseif #remoteRepo.files > 0 then
						if string.split(httpService:JSONDecode(http.GET({Url = remoteRepo.url, path = ("/contents/" .. value.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user}).Body).name, ".")[2] == "luau" then
							if not table.find(remoteRepo.files, value, 1) then
								table.insert(remoteRepo.files, value)
							end
						end	
					end
				end
				deep_search(value)
			end
		end
	end
	local files : http.get = http.GET({Url = remoteRepo.url, path = ("/git/trees/" .. remoteRepo.branchToUse .. "?recursive=1"), token = remoteRepo.token, username = remoteRepo.user}).Body
	deep_search(httpService:JSONDecode(files))
	localRepo:getAllAviableScriptDocuments(remoteRepo.name)
	pageModule.loadingAnimation(main, 3)
	for _, file in pairs(remoteRepo.files) do
		local fileName : string = string.split(httpService:JSONDecode(http.GET({Url = remoteRepo.url, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user}).Body).name, ".")[1]
		if localRepo.scriptDocuments[fileName] then
			table.insert(local_remote_Files, fileName)
			if localRepo.scriptDocuments[fileName] then
				localRepo:setAttribute(localRepo.scriptDocuments[fileName], file.path, remoteRepo.name)
			end
		end
	end
	if #remoteRepo.files > 0 or #localRepo.scriptDocuments > 0 then
		pageModule.loadingAnimation(main, 3)
		createUI()
	end
end
function setupRepository(repoName)
	repositories = dataMod.getData(plugin, "REPOSITORIES")
	local repoData : {["NAME"] : string, ["USER"] : string, ["URL"] : string, ["KEY"] : string}
	repoData = repositories[repoName]
	remoteRepo = remoteReporCreator.remoteRepository(repoData.NAME, repoData.URL, repoData.KEY, repoData.USER)
	localRepo = localRepoModule.newLocalRepo()
	local status : boolean = http.GET({Url = remoteRepo.url, path = "", token = remoteRepo.token, username = remoteRepo.user}).Success
	local branchesRequest = http.GET({Url = remoteRepo.url, path = "/branches", token = remoteRepo.token, username = remoteRepo.user}).Body
	for c = 1, #httpService:JSONDecode(branchesRequest), 1 do
		table.insert(remoteRepo.branches, httpService:JSONDecode(branchesRequest )[c].name)
	end
	if #remoteRepo.branches > 0 then
		pageModule.currentPages.repository.branch.Text = ("< "..remoteRepo.branches[index].." >")
		remoteRepo.branchToUse = remoteRepo.branches[index]
		if filesStatus == true then
			local succes, err = pcall(getAllFiles)
			filesStatus = succes
		end
	elseif #remoteRepo.branches == 0 then
		print("Target repository has no branches, new branch will be create with first push - Gitlink")
	end	
	if status then return status end
end
button.Click:Connect(function()
	if main then
		main.Enabled = true
	elseif main == nil then
		main = plugin:CreateDockWidgetPluginGui(id, widgetInfo)
		main.Title = ("GitLink")
		local function login()
			currentPage = pageModule.changePage("login", main)
			repositories = dataMod.getData(plugin, "REPOSITORIES")
			loginMod.setName(pageModule.currentPages.login.welcomeLabel)
			if repositories then
				if len(repositories) > 0 then
					for _, button in pairs(pageModule.currentPages.login:WaitForChild("Frame"):GetChildren()) do
						if button:IsA("TextButton") and not (button.Name == "add") then
							button:Destroy()
						end
					end
					for name, repo in pairs(repositories) do
						local button = script.uiElements.button:Clone()
						button.Parent = pageModule.currentPages.login.Frame
						button.Text = name
					end
				end
			end
		end
		local function createRepositoryUI(repoName) : (string) -> any
			currentPage = pageModule.changePage("repository", main)
			local status : boolean = setupRepository(repoName)
			if status == true then
				pageModule.currentPages.repository.repositoryName.Text = remoteRepo.name
			elseif status == false then
				print("Repository is empty or an error has occured - GitLink")
			else
				warn("Failed to get data! Check your URL and API KEY! - GitLink")
			end
		end
		if not (dataMod.getData(plugin, "DEFAULTREPOSITORIES") == nil) then
			local ids : {[number] : number} = {}
			for _ , repo in pairs(dataMod.getData(plugin, "DEFAULTREPOSITORIES")) do
				if not table.find(ids, repo.place, 1) then
					table.insert(ids, repo.place)
				end	
				if #ids == 0 then
					table.insert(ids, repo.place)
				end
			end
			if #ids > 0 then
				if table.find(ids, game.PlaceId, 1) then
					for _ , repo in pairs(dataMod.getData(plugin, "DEFAULTREPOSITORIES")) do
						if repo.place == game.PlaceId then
							createRepositoryUI(repo.name)
						end
					end
				else
					login()
				end
			elseif #ids == 0 then
				login()
			end
		else
			login()
		end
	end
end)
pageModule.currentPages.login.select.MouseButton1Down:Connect(function()
	if pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Name == "add" then
		currentPage = pageModule.changePage("creatorPage", main)
	else
		currentPage = pageModule.changePage("repository", main)
		local status : boolean = setupRepository(pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Text)
		if status == true then
			pageModule.currentPages.repository.repositoryName.Text = remoteRepo.name
		elseif status == false then
			print("Repository is empty or an error has occured - GitLink")
		else
			warn("Failed to get data! Check your URL and API KEY! - GitLink")
		end
	end
end)
local currentEditedRepository: string
pageModule.currentPages.login.edit.MouseButton1Down:Connect(function()
	currentEditedRepository = pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Text
	if len(dataMod.getData(plugin, "REPOSITORIES")[pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Text]) > 0 then
		currentPage = pageModule.changePage("editPage", main)
		currentPage.TextLabel.Text = ("Edit: "..pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Text)
		currentPage.key.Text = ("<font color='rgb(255,0,0)'>API Key can only be changed!</font>")
		currentPage.name.Text = dataMod.getData(plugin, "REPOSITORIES")[pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Text].USER
		currentPage.url.Text = ("https://github.com/"..dataMod.getData(plugin, "REPOSITORIES")[pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Text].USER.."/"..dataMod.getData(plugin, "REPOSITORIES")[pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Text].NAME)
		if not (dataMod.getData(plugin, "DEFAULTREPOSITORIES") == nil) then
			local ids : {[number] : number} = {}
			for _ , repo in pairs(dataMod.getData(plugin, "DEFAULTREPOSITORIES")) do
				if not table.find(ids, repo.place, 1) then
					table.insert(ids, repo.place)
				end	
				if #ids == 0 then
					table.insert(ids, repo.place)
				end
			end
			if #ids > 0 then
				for _, id in pairs(ids) do
					if id == game.PlaceId then
						for _ , repo in pairs(dataMod.getData(plugin, "DEFAULTREPOSITORIES")) do
							if repo.place == game.PlaceId then
								currentPage.autoLoginButton.Text = "Yes"
							end
						end
					end
				end
			elseif #ids == 0 then
				currentPage.autoLoginButton.Text = "No"
			end
		else
			currentPage.autoLoginButton.Text = "No"
		end
	else
		print("Couldn't access repository data - Gitlink")
	end
end)
pageModule.currentPages.editPage.autoLoginButton.MouseButton1Down:Connect(function()
	if pageModule.currentPages.editPage.autoLoginButton.Text == "Yes" then
		pageModule.currentPages.editPage.autoLoginButton.Text = "No"
	elseif pageModule.currentPages.editPage.autoLoginButton.Text == "No" then
		pageModule.currentPages.editPage.autoLoginButton.Text = "Yes"
	end
end)
pageModule.currentPages.editPage.finish.MouseButton1Down:Connect(function()
	currentEditedRepository = ""
	local page : Frame = pageModule.currentPages.editPage
	local request : dataMod.repoData = dataMod.updateRepoData(page.url.Text, page.key.Text, page.name.Text, plugin)
	page.url.Text = ""
	page.key.Text = ""
	page.name.Text = ""
	if request.code == "success" then
		print("Repository data updated successfully - Gitlink")
	end
	local repo : {["NAME"] : string, ["USER"] : string, ["URL"] : string, ["KEY"] : string} = dataMod.getData(plugin, "REPOSITORIES")[request.name]
	if pageModule.currentPages.editPage.autoLoginButton.Text == "Yes" then
		if not (dataMod.getData(plugin, "DEFAULTREPOSITORIES") == nil) then
			dataMod.addDefaultRepository(plugin, repo.NAME)
		end	
	end
	if pageModule.currentPages.editPage.autoLoginButton.Text == "No" then
		if not (dataMod.getData(plugin, "DEFAULTREPOSITORIES") == nil) then
			dataMod.removeDefaultRepository(plugin, repo.NAME)
		end
	end
	currentPage = pageModule.changePage("login", main)
end)
pageModule.currentPages.repository.home.MouseButton1Down:Connect(function()
	if filesStatus == true then
		currentPage = pageModule.changePage("login", main)
		pageModule.currentPages.repository.branch.Text = ("< ".."Super-Branch".." >")
		pageModule.currentPages.repository.repositoryName.Text = "Super-Repository-Name"
		remoteRepo = nil
		filesStatus = true
		loginMod.setName(pageModule.currentPages.login.welcomeLabel)
		if repositories then
			if len(repositories) > 0 then
				for _, button in pairs(pageModule.currentPages.login:WaitForChild("Frame"):GetChildren()) do
					if button:IsA("TextButton") and not (button.Name == "add") then
						button:Destroy()
					end
				end
				for name, repo in pairs(repositories) do
					local button : TextButton = script.uiElements.button:Clone()
					button.Parent = pageModule.currentPages.login.Frame
					button.Text = name
				end
			end
		end
		for _, button in pairs(pageModule.currentPages.repository.list.ScrollingFrame:GetChildren()) do
			if button:IsA("TextButton") then
				if not (button.Name == "add") then
					button.Parent = nil
				end
			end
		end
	end	
end)
pageModule.currentPages.repository.list.ScrollingFrame.add.MouseButton1Down:Connect(function()
	pageModule.loadingAnimation(main, 2)
	if #game:GetService("Selection"):Get() > 0 then
		for _, item in pairs(game:GetService("Selection"):Get()) do
			if item:IsA("LuaSourceContainer") then
				if #local_remote_Files > 0 then
					if not table.find(local_remote_Files, item.Name, 1) then
						table.insert(localRepo.scriptDocuments, item)
					end
				elseif #localRepo.scriptDocuments == 0 then
					table.insert(localRepo.scriptDocuments, item)
				end
			elseif not item:IsA("LuaSourceContainer") then
				print(item.Name.." is not a script! - GitLink")
			end
		end
	else
		print("No instances selected! - GitLink")
	end
	if filesStatus == true then
		local succes : boolean, err : string = pcall(getAllFiles)
		filesStatus = succes
	end
end)
pageModule.currentPages.repository.branch.left.MouseButton1Down:Connect(function()
	if index >= 2 and filesStatus == true then
		index = index - 1
		pageModule.currentPages.repository.branch.Text = ("< "..remoteRepo.branches[index].." >")
		remoteRepo.branchToUse = remoteRepo.branches[index]
	elseif (index == #remoteRepo.branches) and filesStatus == true then
		index = index + 1
		pageModule.currentPages.repository.branch.Text = ("< "..remoteRepo.branches[index].." >")
		remoteRepo.branchToUse = remoteRepo.branches[index]
	elseif index == 1 and filesStatus == true then
		index = index + 1
		pageModule.currentPages.repository.branch.Text = ("< "..remoteRepo.branches[index].." >")
		remoteRepo.branchToUse = remoteRepo.branches[index]
	end
	task.wait(2)
	if filesStatus == true then
		local succes : boolean, err : string = pcall(getAllFiles)
		filesStatus = succes
	end
end)
pageModule.currentPages.repository.branch.right.MouseButton1Down:Connect(function()
	if not (#remoteRepo.branches == 0) and filesStatus == true then
		if not (index == #remoteRepo.branches) then
			index = index + 1
			pageModule.currentPages.repository.branch.Text = ("< "..remoteRepo.branches[index].." >")
			remoteRepo.branchToUse = remoteRepo.branches[index]
		elseif index == #remoteRepo.branches then
			index = 1
			pageModule.currentPages.repository.branch.Text = ("< "..remoteRepo.branches[index].." >")
			remoteRepo.branchToUse = remoteRepo.branches[index]
		end
	end
	task.wait(2)
	if filesStatus == true then
		local succes : boolean, err : string = pcall(getAllFiles)
		filesStatus = succes
	end
end)
pageModule.currentPages.creatorPage.autoLoginButton.MouseButton1Down:Connect(function()
	if pageModule.currentPages.creatorPage.autoLoginButton.Text == "Yes" then
		pageModule.currentPages.creatorPage.autoLoginButton.Text = "No"
	elseif pageModule.currentPages.creatorPage.autoLoginButton.Text == "No" then
		pageModule.currentPages.creatorPage.autoLoginButton.Text = "Yes"
	end
end)
pageModule.currentPages.creatorPage.finish.MouseButton1Down:Connect(function()
	local page : Frame= pageModule.currentPages.creatorPage
	local request : dataMod.repoData = dataMod.createRepoData(page.url.Text, page.key.Text, page.name.Text, plugin)
	page.url.Text = ""
	page.key.Text = ""
	page.name.Text = ""
	if request.code == "success" then
		repositories = dataMod.getData(plugin, "REPOSITORIES")
		if repositories then
			if len(repositories) > 0 then
				for _, button in pairs(pageModule.currentPages.login:WaitForChild("Frame"):GetChildren()) do
					if button:IsA("TextButton") and not (button.Name == "add") then
						button:Destroy()
					end
				end
				for name, repo in pairs(repositories) do
					local button : TextButton = script.uiElements.button:Clone()
					button.Parent = pageModule.currentPages.login.Frame
					button.Text = name
				end
			end
		end
	end	
	if pageModule.currentPages.creatorPage.autoLoginButton.Text == "Yes" then
		dataMod.addDefaultRepository(plugin, request.name)
	end
	currentPage = pageModule.changePage("login", main)
end)
pageModule.currentPages.creatorPage.exit.MouseButton1Down:Connect(function()
	pageModule.currentPages.creatorPage.url.Text = ""
	pageModule.currentPages.creatorPage.key.Text = ""
	pageModule.currentPages.creatorPage.name.Text = ""
	currentPage = pageModule.changePage("login", main)
end)
pageModule.currentPages.editPage.exit.MouseButton1Down:Connect(function()
	currentEditedRepository = ""
	pageModule.currentPages.editPage.url.Text = ""
	pageModule.currentPages.editPage.key.Text = ""
	pageModule.currentPages.editPage.name.Text = ""
	currentPage = pageModule.changePage("login", main)
end)
pageModule.currentPages.repository.push.MouseButton1Down:Connect(function()
	pageModule.currentPages.repository.commitUI.Visible = true
	pageModule.currentPages.repository.commitUI.Interactable = true
	pageModule.currentPages.repository.commitUI.title.Text = ("Commit to "..remoteRepo.name)
end)
pageModule.currentPages.repository.commitUI.exit.MouseButton1Down:Connect(function()
	pageModule.currentPages.repository.commitUI.Visible = false
	pageModule.currentPages.repository.commitUI.Interactable = false
end)
pageModule.currentPages.repository.commitUI.commitButton.MouseButton1Down:Connect(function()
	if string.len(pageModule.currentPages.repository.commitUI.commitDesc.Text) > 0 then
		if filesStatus == true then
			local succes : boolean, err : string = pcall(getAllFiles)
			filesStatus = succes
		end
		if filesStatus == true then
			if #remoteRepo.files > 0 then
				for _, file in pairs(remoteRepo.files) do
					if not table.find(local_remote_Files, string.split(httpService:JSONDecode(http.GET({Url = remoteRepo.url, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user}).Body).name, ".")[1], 1) then
						local request : http.delete = http.DELETE({Branch = remoteRepo.branchToUse, SHA = file.sha, Url = remoteRepo.url, message = pageModule.currentPages.repository.commitUI.commitDesc.Text, username = remoteRepo.user, token = remoteRepo.token, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse)})
						if request.Success == true then
							print("Delated a file in repository")
						else
							warn("Code: " .. request.StatusCode .. request.StatusMessage)
						end
					else 
						local fileContent : http.get = http.GET({Url = remoteRepo.url, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user})
						local localFile : ScriptDocument? = localRepo.scriptDocuments[string.split(httpService:JSONDecode(http.GET({Url = remoteRepo.url, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user}).Body).name, ".")[1]]
						if not (http.DecodeBase64(httpService:JSONDecode(fileContent.Body).content) == localFile.Source) then
							local request : http.put = http.PUT({Branch = remoteRepo.branchToUse, Message = pageModule.currentPages.repository.commitUI.commitDesc.Text, SHA = file.sha, Url = remoteRepo.url, fileContent = localFile.Source, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user})
							if request.Success == true then
								print("Successfully pushed chages to: " .. localFile.Name)
							else
								warn("Code: " .. request.StatusCode .. request.StatusMessage)
							end
						end
					end	
				end
			end
			if #localRepo.scriptDocuments > 0 then
				for _, file in pairs(localRepo.scriptDocuments) do
					if not table.find(local_remote_Files, file.Name, 1) then
						if remoteRepo.branchToUse == "" and #remoteRepo.branches == 0 and #remoteRepo.files == 0 then
							remoteRepo.branchToUse = "main"
						end
						local request : http.put = http.PUT({Branch = remoteRepo.branchToUse, Message = pageModule.currentPages.repository.commitUI.commitDesc.Text, SHA = "", Url = remoteRepo.url, fileContent = file.Source, path = ("/contents/" .. "src/" .. file.Name .. ".luau" .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user})
						if request.Success == true then
							print("Successfully pushed chages to: " .. file.Name)
						else
							warn("Code: " .. request.StatusCode .. request.StatusMessage)
						end
					end	
				end
			end
			pageModule.currentPages.repository.commitUI.Visible = false
			pageModule.currentPages.repository.commitUI.Interactable = false
			if filesStatus == true then
				local succes : boolean, err : string = pcall(getAllFiles)
				filesStatus = succes
			end
		else
			print("Commit message is required for this action! Please enter commit name.")
		end	
	end	
end)
pageModule.currentPages.repository.fetch.MouseButton1Down:Connect(function()
	pageModule.currentPages.repository.fetchUI.Visible = true
	pageModule.currentPages.repository.fetchUI.Interactable = true
	pageModule.currentPages.repository.fetchUI.title.Text = ("Change " .. #remoteRepo.files + #localRepo.scriptDocuments .. " files")
	if #localRepo.scriptDocuments - #remoteRepo.files > 0 then
		pageModule.currentPages.repository.fetchUI.changes.Text = ("By clicking continue " .. #localRepo.scriptDocuments - #remoteRepo.files .. " local file(s) will be delated.")
	else
		pageModule.currentPages.repository.fetchUI.changes.Text = ("By clicking continue no local file(s) will be delated.")
	end	
end)
pageModule.currentPages.repository.fetchUI.exit.MouseButton1Down:Connect(function()
	pageModule.currentPages.repository.fetchUI.Visible = false
	pageModule.currentPages.repository.fetchUI.Interactable = false
end)
pageModule.currentPages.repository.fetchUI.continue.MouseButton1Down:Connect(function()
	if filesStatus == true then
		local succes : boolean, err : string = pcall(getAllFiles)
		filesStatus = succes
	end
	if filesStatus == true then
		if #remoteRepo.files > 0 then
			for _, file in pairs(remoteRepo.files) do
				if table.find(local_remote_Files, string.split(httpService:JSONDecode(http.GET({Url = remoteRepo.url, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user}).Body).name, ".")[1], 1) then
					local fileContent : http.get = http.GET({Url = remoteRepo.url, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user})
					local localFile : ScriptDocument? = localRepo.scriptDocuments[string.split(httpService:JSONDecode(http.GET({Url = remoteRepo.url, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user}).Body).name, ".")[1]]
					if fileContent.Success == true then
						if not (http.DecodeBase64(httpService:JSONDecode(fileContent.Body).content) == localFile.Source) then
							localFile.Source = http.DecodeBase64(httpService:JSONDecode(fileContent.Body).content)
							print("Successfully updated: " .. localFile.Name)
						end
					else
						warn("Code: " .. fileContent.StatusCode .. fileContent.StatusMessage)
					end
				else
					local file : http.get = http.GET({Url = remoteRepo.url, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user})
					if file.Success == true then
						local localFile : Script = Instance.new("Script", game.ServerScriptService)
						localFile.Source = http.DecodeBase64(httpService:JSONDecode(file.Body).content)
						localFile.Name = string.split(httpService:JSONDecode(file.Body).name, ".")[1]
						localRepo:setAttribute(localFile, httpService:JSONDecode(file.Body).path, remoteRepo.name)
					end
				end	
			end
			for _, file in pairs(localRepo.scriptDocuments) do
				if not table.find(local_remote_Files, file.Name, 1) then
					print("Successfully delated " .. file.Name)
					file.Parent = nil
				end
			end
			pageModule.currentPages.repository.fetchUI.Visible = false
			pageModule.currentPages.repository.fetchUI.Interactable = false
			if filesStatus == true then
				local succes : boolean, err : string = pcall(getAllFiles)
				filesStatus = succes
			end
		end
	end
end)
local delateStatus : boolean = false
pageModule.currentPages.editPage.delate.MouseButton1Down:Connect(function()
	if delateStatus == false then
		delateStatus = true
		pageModule.currentPages.editPage.delate.TextColor3 = Color3.new(1, 0.0561074, 0)
		task.wait(2)
		delateStatus = false
		pageModule.currentPages.editPage.delate.TextColor3 = Color3.new(0.998779, 1, 0.979385)
	end
	if delateStatus == true then
		dataMod.removeRepositoryData(plugin, currentEditedRepository)
		if dataMod.getData(plugin, "DEFAULTREPOSITORIES")[currentEditedRepository] then
			dataMod.removeDefaultRepository(plugin, currentEditedRepository)
		end
		currentEditedRepository = ""
		repositories = dataMod.getData(plugin, "REPOSITORIES")
		if repositories then
			if len(repositories) > 0 then
				for _, button in pairs(pageModule.currentPages.login:WaitForChild("Frame"):GetChildren()) do
					if button:IsA("TextButton") and not (button.Name == "add") then
						button:Destroy()
					end
				end
				for name, repo in pairs(repositories) do
					local button : TextButton = script.uiElements.button:Clone()
					button.Parent = pageModule.currentPages.login.Frame
					button.Text = name
				end
			end
		end
		currentPage = pageModule.changePage("login", main)
	end
end)
pageModule.currentPages.repository.list.MouseEnter:Connect(function()
	for _, button in pairs(pageModule.currentPages.repository.list.ScrollingFrame:GetChildren()) do
		if button:IsA("TextButton") then
			if button.Name == "file" then
				button.MouseButton1Down:Connect(function()
					currentFile = button.Text
					button.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
					for _, button in pairs(pageModule.currentPages.repository.list.ScrollingFrame:GetChildren()) do
						if button:IsA("TextButton") then
							if button.Name == "file" and not (button.Text == currentFile) then
								button.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
							end	
						end
					end
				end)
			end	
		end
	end
end)
pageModule.currentPages.repository.file.delate.MouseButton1Down:Connect(function()
	if filesStatus == true then
		for _, file in pairs(localRepo.scriptDocuments) do
			if file.Name == currentFile then
				if file:GetAttribute("path") then
					file:SetAttribute("path", nil)
				end
			end
		end
		for _, file in pairs(remoteRepo.files) do
			if currentFile == string.split(httpService:JSONDecode(http.GET({Url = remoteRepo.url, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse), token = remoteRepo.token, username = remoteRepo.user}).Body).name, ".")[1] then
				local request : http.delete = http.DELETE({Branch = remoteRepo.branchToUse, SHA = file.sha, Url = remoteRepo.url, message = "Delated " .. file.path, username = remoteRepo.user, token = remoteRepo.token, path = ("/contents/" .. file.path .. "?ref=" .. remoteRepo.branchToUse)})
				if request.Success == true then
					print("Delated a file in repository")
				else
					warn("Code: " .. request.StatusCode .. request.StatusMessage)
				end
			end
		end
	end
	currentFile = ""
	if filesStatus == true then
		local succes : boolean, err : string = pcall(getAllFiles)
		filesStatus = succes
	end
end)
game:GetService("RunService").Heartbeat:Connect(function()
	if not (currentPage == nil) then
		loginMod.buttonsSelection(pageModule.currentPages.login)
	end	
end)