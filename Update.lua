vehiculecontrole.Functions.GetVersionScript = function(CURRENT_VERSION, SCRIPT_NAME)
    PerformHttpRequest("https://github.com/Bibiflox/Bibi-VehiculeControle/main/versions.json", function (_, data, __)
        if data ~= nil then
            local SCRIPT_LIST = json.decode(data)
            for _, value in pairs ( SCRIPT_LIST ) do 
                if value.name == SCRIPT_NAME then
                    if value.version == CURRENT_VERSION then
                        print("^2[" ..SCRIPT_NAME.. "] VERSION IS LATEST\n[" ..SCRIPT_NAME.. "] VERSION TITLE ^3" .. value.version_name.."^2\n".."[" ..SCRIPT_NAME.. "] ^3" .. value.version_desc.."^2.^7")
                    else
                        print("^8[" ..SCRIPT_NAME.. "] ^1IS OUTDATED, NEEDS TO BE UPDATED!^8\n[" ..SCRIPT_NAME.. "] ^1LATEST VERSION IS^8 ^3" .. value.version .. "^8.^7")
                        vehiculecontrole.Functions.CreateUpdateLoop("^8[" ..SCRIPT_NAME.. "] ^1IS OUTDATED, NEEDS TO BE UPDATED!^8\n[" ..SCRIPT_NAME.. "] ^1LATEST VERSION IS^8 ^3" .. value.version .. "^8.^7")
                    end
                end
            end
        else
            print("[VehiculeControle] Les versions ne sont pas accessibles. Attendez s'il vous plaît et ne dérangez pas le développeur, cela passera bientôt !")
        end
    end)
end

vehiculecontrole.Functions.CreateUpdateLoop = function(PRINT)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(60000)
            print(PRINT)
        end
    end)
end

Citizen.CreateThread(function()
    Citizen.Wait(500)
    vehiculecontrole.Functions.GetVersionScript(GetResourceMetadata("ls-core", "version"), "ls-core")
end)

exports("CheckVersion", vehiculecontrole.Functions.GetVersionScript)

