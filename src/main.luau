local reomoteReporCreator = require(script.reomoteRepo)
--local localRepo = require(script.localRepo)
--local reomoteRepo = reomoteReporCreator.reomoteRepository("The-Prototyping-Place", "https://api.github.com/repos/kol11kol/The-Prototyping-Place")

--https://api.github.com/repos/OWNER/REPO/branches

--local newLocalRepo = localRepo.newLocalRepo()
--reomoteRepo:GetBranches()
--newLocalRepo:getAviableScriptDocuments()
--reomoteRepo:GetTrees()
--reomoteRepo:GetFiles()
--print(reomoteRepo.files)
local loginMod = require(script.loginPageModule)
local dataMod = require(script.dataModule)
local pageModule = require(script.pageModule)
local creatorMod = require(script.creatorModule)
local toolbar = plugin:CreateToolbar("GitLink")
local button = toolbar:CreateButton("1", "Open GitLink", "rbxassetid://133834975760872", "Open Gitlink")
local widgetInfo = DockWidgetPluginGuiInfo.new( --size should be minimum 1/4 of screen size
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
--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
pageModule.clonePages()
local main
local id = 0
local currentPage
local repositories = {}
local function len(tab)
	local sum = 0
	for _, v in pairs(tab) do
		sum = sum + 1
	end
	return sum
end
local reomoteRepo
local index = 1
function createReomoteRepository(repoName)
	repositories = dataMod.getData(plugin, "REPOSITORIES")
	local repoData
	repoData = repositories[repoName]
	
	reomoteRepo = reomoteReporCreator.reomoteRepository(repoData.NAME, repoData.URL, repoData.KEY, repoData.USER)
	local status = reomoteRepo:checkRepository()
	reomoteRepo:GetBranches()
	if #reomoteRepo.branches > 0 then
		pageModule.currentPages.repository.branch.Text = ("< "..reomoteRepo.branches[index].." >")
		reomoteRepo.branchToUse = reomoteRepo.branches[index]
		reomoteRepo:GetFiles()
		task.wait(3)
		if #reomoteRepo.files == 0 then
			print("Target repository is empty")
		else
			for _, button in pairs(pageModule.currentPages.repository.list.ScrollingFrame:GetChildren()) do
				if button:IsA("TextButton") and not (button.Name == "add") then
					button.Parent = nil
				end
			end
			for _, file in pairs(reomoteRepo.files) do
				local clone = script.uiElements.file:Clone()
				clone.Parent = pageModule.currentPages.repository.list.ScrollingFrame
				clone.Text = reomoteRepo:getFileName(file)
			end
		end
	elseif #reomoteRepo.branches == 0 then
		print("Target repository has no branches please create a branch - Gitlink")
	end	
	--print(#reomoteRepo.files) -- get all files from that, need to run everytime branch is switched
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
					for name, repo in pairs(repositories) do
						loginMod.createButtons(pageModule.currentPages.login.Frame, name)
					end
				end
			end
		end
		local function createRepositoryUI(repoName)
			currentPage = pageModule.changePage("repository", main)
			local status = createReomoteRepository(repoName)
			if status == "success" then
				pageModule.currentPages.repository.repositoryName.Text = reomoteRepo.name
			elseif status == "failed" then
				print("Repository is empty or an error has occured - GitLink")
			else
				warn("Failed to get data! Check your URL and API KEY! - GitLink")
			end
		end
		if not (dataMod.getData(plugin, "DEFAULTREPOSITORIES") == nil) then
			local ids = {}
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
								createRepositoryUI(repo.name)
							end
						end
					end
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
		local status = createReomoteRepository(pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Text)
		if status == "success" then
			pageModule.currentPages.repository.repositoryName.Text = reomoteRepo.name
		elseif status == "failed" then
			print("Repository is empty or an error has occured - GitLink")
		else
			warn("Failed to get data! Check your URL and API KEY! - GitLink")
		end
	end
end)
pageModule.currentPages.login.edit.MouseButton1Down:Connect(function()
	if len(dataMod.getData(plugin, "REPOSITORIES")[pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Text]) > 0 then
		currentPage = pageModule.changePage("editPage", main)
		currentPage.TextLabel.Text = ("Edit: "..pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Text)
		currentPage.key.Text = ("<font color='rgb(255,0,0)'>API Key can only be changed!</font>")
		currentPage.name.Text = dataMod.getData(plugin, "REPOSITORIES")[pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Text].USER
		currentPage.url.Text = ("https://github.com/"..dataMod.getData(plugin, "REPOSITORIES")[pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Text].USER.."/"..dataMod.getData(plugin, "REPOSITORIES")[pageModule.currentPages.login.Frame.UIPageLayout.CurrentPage.Text].NAME)
		if not (dataMod.getData(plugin, "DEFAULTREPOSITORIES") == nil) then
			local ids = {}
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
	local page = pageModule.currentPages.editPage
	local request = dataMod.updateRepoData(page.url.Text, page.key.Text, page.name.Text, plugin)
	page.url.Text = ""
	page.key.Text = ""
	page.name.Text = ""
	if request.code == "success" then
		print("Repository data updated successfully - Gitlink")
	end
	local repo = dataMod.getData(plugin, "REPOSITORIES")[request.name]
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
	--[[
		
		TODO: function to remove default repository
		
		]]
		currentPage = pageModule.changePage("login", main)
end)
pageModule.currentPages.repository.branch.right.MouseButton1Down:Connect(function()
	if not (#reomoteRepo.branches == 0) then
		if not (index == #reomoteRepo.branches) then
			index = index + 1
			pageModule.currentPages.repository.branch.Text = ("< "..reomoteRepo.branches[index].." >")
			reomoteRepo.branchToUse = reomoteRepo.branches[index]
		elseif index == #reomoteRepo.branches then
			index = 1
			pageModule.currentPages.repository.branch.Text = ("< "..reomoteRepo.branches[index].." >")
			reomoteRepo.branchToUse = reomoteRepo.branches[index]
		end
	end	
end)
pageModule.currentPages.repository.home.MouseButton1Down:Connect(function()
	currentPage = pageModule.changePage("login", main)
	pageModule.currentPages.repository.branch.Text = ("< ".."Super-Branch".." >")
	pageModule.currentPages.repository.repositoryName.Text = "Super-Repository-Name"
	reomoteRepo = nil
	loginMod.setName(pageModule.currentPages.login.welcomeLabel)
	if repositories then
		if len(repositories) > 0 then
			for name, repo in pairs(repositories) do
				loginMod.createButtons(pageModule.currentPages.login.Frame, name)
			end
		end
	end
end)
local addFiles = {}
pageModule.currentPages.repository.list.ScrollingFrame.add.MouseButton1Down:Connect(function()
	task.wait(2)
	if #game:GetService("Selection"):Get() > 0 then
		for _, item in pairs(game:GetService("Selection"):Get()) do
			if item:IsA("LuaSourceContainer") then
				if #addFiles > 0 then
					if not table.find(addFiles, item, 1) then
						table.insert(addFiles, item)
					end
				else
					table.insert(addFiles, item)
				end
			elseif not item:IsA("LuaSourceContainer") then
				print(item.Name.." is not a script! - GitLink")
			end
		end
	else
		print("No instances selected! - GitLink")
	end	
end)
pageModule.currentPages.repository.branch.left.MouseButton1Down:Connect(function()
	if index >= 2 then
		index = index - 1
		pageModule.currentPages.repository.branch.Text = ("< "..reomoteRepo.branches[index].." >")
		reomoteRepo.branchToUse = reomoteRepo.branches[index]
	elseif (index == #reomoteRepo.branches) then
		index = index + 1
		pageModule.currentPages.repository.branch.Text = ("< "..reomoteRepo.branches[index].." >")
		reomoteRepo.branchToUse = reomoteRepo.branches[index]
	elseif index == 1 then
		index = index + 1
		pageModule.currentPages.repository.branch.Text = ("< "..reomoteRepo.branches[index].." >")
		reomoteRepo.branchToUse = reomoteRepo.branches[index]
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
	local page = pageModule.currentPages.creatorPage
	local request = dataMod.createRepoData(page.url.Text, page.key.Text, page.name.Text, plugin)
	page.url.Text = ""
	page.key.Text = ""
	page.name.Text = ""
	if request.code == "success" then
		repositories = dataMod.getData(plugin, "REPOSITORIES")
		if repositories then
			if len(repositories) > 0 then
				for name, repo in pairs(repositories) do
					loginMod.createButtons(pageModule.currentPages.login.Frame, name)
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
	pageModule.currentPages.editPage.url.Text = ""
	pageModule.currentPages.editPage.key.Text = ""
	pageModule.currentPages.editPage.name.Text = ""
	currentPage = pageModule.changePage("login", main)
end)
pageModule.currentPages.repository.push.MouseButton1Down:Connect(function()
	pageModule.currentPages.repository.commitUI.Visible = true
	pageModule.currentPages.repository.commitUI.Interactable = true
	pageModule.currentPages.repository.commitUI.title.Text = ("Commit to "..reomoteRepo.name)
end)
pageModule.currentPages.repository.commitUI.exit.MouseButton1Down:Connect(function()
	pageModule.currentPages.repository.commitUI.Visible = false
	pageModule.currentPages.repository.commitUI.Interactable = false
end)
pageModule.currentPages.repository.commitUI.commitButton.MouseButton1Down:Connect(function()
	reomoteRepo:GetFiles()
	print(reomoteRepo.branchToUse)
	for _, file in pairs(reomoteRepo.files) do
		print(file.name, file.path)
	end
	pageModule.currentPages.repository.commitUI.Visible = false
	pageModule.currentPages.repository.commitUI.Interactable = false
end)
game:GetService("RunService").Heartbeat:Connect(function()
	if not (currentPage == nil) then
		loginMod.buttonsSelection(pageModule.currentPages.login)
	end	
end)





--local textArea = script.Parent.Text
--local scrollFrame = script.Parent

--textArea:GetPropertyChangedSignal("TextFits"):Connect(function()
--	while textArea.TextFits == false do
--		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollFrame.CanvasSize.Y.Offset + 16)
--		scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset - scrollFrame.AbsoluteWindowSize.Y)
--	end
--end)

--textArea:GetPropertyChangedSignal("TextBounds"):Connect(function()
--	if scrollFrame.CanvasSize.Y.Offset > textArea.TextBounds.Y + 16 then
--		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, textArea.TextBounds.Y)
--		scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset - scrollFrame.AbsoluteWindowSize.Y)
--	end
--end)















--[[


		TODO: make frame visible when pressing ctrl + G


]]
--local function buttonStyle(button, newText)
--	button.Text = newText
--end
--mainFrame.branch.MouseEnter:Connect(function() -- make user select branch first
--	mainFrame.branch.Text = ("  Branch: [select]")
--end)
--mainFrame.branch.MouseLeave:Connect(function()
	--if (string.len(reomoteRepo.branchToUse) == 0) then
	--	mainFrame.branch.Text = "  Branch: none"
	--else
	--	mainFrame.branch.Text = ("  Branch: "..reomoteRepo.branchToUse)
	--end
--end)
--mainFrame.branch.MouseButton1Click:Connect(function()
--	mainFrame.branches.Visible = true
--end)
--mainFrame.branches.MouseLeave:Connect(function()
--	mainFrame.branches.Visible = false
--end)
--mainFrame.branches.UISizeConstraint.MaxSize = Vector2.new(190, #reomoteRepo.branches * 30)
--local branchesButtons = {}
--for _, branch in pairs(reomoteRepo.branches) do
--	local newBranch = script.branch:Clone()
--	newBranch.Parent = mainFrame.branches
--	newBranch.Text = branch
--	newBranch.MouseButton1Down:Connect(function()
--		reomoteRepo.branchToUse = branch
--		mainFrame.branches.Visible = false
--		mainFrame.branch.Text = ("  Branch: "..reomoteRepo.branchToUse)
--	end)
--end
--while task.wait() do
--	local scripts = game:GetService("ScriptEditorService"):GetScriptDocuments()
--	for n, s in pairs(scripts) do
--		print(n,s)
--	end
--end	
--for a, b in pairs(reomoteRepo.files) do
--	print(a, b.path, b.sha)
--	for c, d in pairs(b) do
--		print(c, d)
--	end
--end
--[[



		add --!git to make script work with plugin



]]
