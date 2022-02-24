## aimedic
a simple NPC Medic script for QBcore drag the file into your resources open config and set prices to match your servers economy use the command /medic enjoy let me know what improvements i can make this is my first script i have upload

### License by https://github.com/NightRider18133/aimedic/


You need to add this in your qb-ambulancejob client/main.lua
```
RegisterNetEvent('hospital:client:npcHospital', function()
    print("Hello")
    local bedId = GetAvailableBed()
    print(bedId)
    if bedId then
        TriggerServerEvent("hospital:server:SendToBed", bedId, true)
    else
        QBCore.Functions.Notify(Lang:t('error.beds_taken'), "error")
    end
end)

```