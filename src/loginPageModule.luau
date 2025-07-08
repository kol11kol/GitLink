local lPage = {}
function lPage.buttonsSelection(loginPage)
	for _, button in pairs(loginPage.Frame:GetDescendants()) do
		if button:IsA("TextButton") then
			if button == loginPage.Frame.UIPageLayout.CurrentPage then
				button.TextColor3 = Color3.new(1, 1, 1)
				if button.Name == "add" then
					loginPage.edit.Visible = false
				else
					loginPage.edit.Visible = true
				end
			else
				button.TextColor3 = Color3.new(0.478431, 0.478431, 0.478431)
			end
		end
	end
end
function lPage.setName(label)
	label.Text = ("Welcome, "..game:GetService("Players"):GetNameFromUserIdAsync(game:GetService("StudioService"):GetUserId()).."!")
end
function lPage.createButtons(frame, repo)
	for _, button in pairs(frame:GetChildren()) do
		if button:IsA("TextButton") and not (button.Name == "add") then
			button:Destroy()
		end
	end
	local button = script.Parent.uiElements.button:Clone()
	button.Parent = frame
	button.Text = repo
end
return lPage