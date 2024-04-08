
function checkLatestVersion()
    local url = "https://github.com/Bibiflox/Bibi-VehiculeControle"
    
    PerformHttpRequest(url, function(statusCode, resultData, headers)
        local data = json.decode(resultData)

        if data and data.object and data.object.sha then
            local latestCommitSha = data.object.sha
            local currentCommitSha = GetCurrentCommitSha() 

            if latestCommitSha == currentCommitSha then
                print("Script Vehiculecontrole à jour !")
            else
                print("Une nouvelle version de Vehiculecontrole est disponible.
                https://github.com/Bibiflox/Bibi-VehiculeControle")
            end
        else
            print("Impossible de vérifier la version depuis GitHub.")
        end
    end, 'GET', '', {['Content-Type'] = 'application/json'})
end


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        checkLatestVersion()
    end
end)
