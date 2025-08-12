local pMod = {}

local loadingAnimationCalled : boolean = false
local tween : Tween
local clone : Frame


function pMod.loadingAnimation(main : DockWidgetPluginGui, mT : number, actionText : string) : (DockWidgetPluginGui, number, string) -> any?
	local function animation(clone : Frame) : (Frame) -> any?
		loadingAnimationCalled = true
		clone = script.Parent.Parent.pages.loadingScreen:Clone()
		clone.Parent = main
		clone.loading.Rotation = 0
		tween = game:GetService("TweenService"):Create(clone.loading.UIGradient, TweenInfo.new(mT, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {Rotation = 180})
		tween:Play()
		tween.Completed:Connect(function()
			loadingAnimationCalled = false
			clone.Parent = nil
		end)
		local i : number = 0
		repeat
			i += 1
			if clone then
				clone.textDisplay.Text = actionText .. "."
				task.wait(.2)
				clone.textDisplay.Text = actionText .. ".."
				task.wait(.5)
				clone.textDisplay.Text = actionText .. "..."
			end
		until i == mT
	end
	if not (loadingAnimationCalled == true) then
		animation()
	else
		if tween then
			tween.Completed:Wait()
			animation()
		else
			animation()
		end
	end
end


function pMod.changePage(targetPage: string, main)
	local page = pMod.currentPages[targetPage]
	if page then
		page.Parent = main
		for _, otherPage in pairs(main:GetChildren()) do
			if otherPage ~= page then
				otherPage.Parent = script.Parent.Parent.clonedPages
			end	
		end
	end
	return page
end


pMod.currentPages = {}
setmetatable(pMod.currentPages, {
	__index = function(self, index)
		for _, p in pairs(self) do
			if index == p.Name then
				return p
			end
		end
	end,
})


function pMod.clonePages()
	if #script.Parent.Parent.clonedPages:GetChildren() > 0 then
		for _, page in pairs(script.Parent.Parent.clonedPages:GetChildren()) do
			page.Parent = nil
		end
	end
	local pages = script.Parent.Parent.pages:GetChildren()
	table.clear(pMod.currentPages)
	for _, page in pairs(pages) do
		local clone = page:Clone()
		clone.Parent = script.Parent.Parent.clonedPages
		table.insert(pMod.currentPages, clone)
	end
end


return pMod