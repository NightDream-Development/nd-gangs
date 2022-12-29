CreateThread(function()
	--version check with github latest version
	PerformHttpRequest(
		"https://raw.githubusercontent.com/NightDream-Development/nd-gangs/main/fxmanifest.lua",
		function(err, text, headers)
			if err ~= 200 then
				return
			end
			local version = GetResourceMetadata(GetCurrentResourceName(), "version")
			local latestVersion = string.match(text, '%sversion \"(.-)\"')
			if version ~= latestVersion then
				print("Ez a script nem friss! Kérlek töltsed le a " .. GetCurrentResourceName() .. " friss verzióját hogy minden bug eltünjön!")
			end
		end,
		"GET"
	)
end)
