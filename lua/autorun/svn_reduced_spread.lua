if SERVER then
    util.AddNetworkString("UpdateCrouchSpread")

    CreateConVar("sv_crouch_spread_multiplier", "0.5", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "")
    CreateConVar("sv_default_spread_multiplier", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "")
    CreateConVar("sv_movement_spread_multiplier", "1.2", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "")

    hook.Add("EntityFireBullets", "ModifyCrouchBulletSpread", function(ent, data)
        if not ent:IsPlayer() then return end

        local weapon = ent:GetActiveWeapon()
        if not IsValid(weapon) then return end

        local className = weapon:GetClass()
        if string.find(className, "crowbar") then return end

        local isCrouching = ent:Crouching()
        local isMoving = ent:GetVelocity():Length() > 0

        local crouchSpreadMultiplier = GetConVar("sv_crouch_spread_multiplier"):GetFloat()
        local defaultSpreadMultiplier = GetConVar("sv_default_spread_multiplier"):GetFloat()
        local movementSpreadMultiplier = GetConVar("sv_movement_spread_multiplier"):GetFloat()

        if isCrouching then
            data.Spread = data.Spread * crouchSpreadMultiplier
        elseif isMoving then
            data.Spread = data.Spread * movementSpreadMultiplier
        else
            data.Spread = data.Spread * defaultSpreadMultiplier
        end

        return true
    end)

    print("Reduced Spread Enabled")
end

if CLIENT then
    hook.Add("PopulateToolMenu", "AddSpreadControlOptions", function()
        spawnmenu.AddToolMenuOption("Utilities", "Nai's Addons", "SpreadControl", "Reduced Spread", "", "", function(panel)
            panel:ClearControls()

            panel:NumSlider("Crouch Spread Multiplier", "sv_crouch_spread_multiplier", 0, 5, 2)
            panel:ControlHelp("Controls how much the spread is reduced when crouching (default: 0.5)")

            panel:NumSlider("Default Spread Multiplier", "sv_default_spread_multiplier", 0, 5, 2)
            panel:ControlHelp("Controls the spread when standing (default: 1)")

            panel:NumSlider("Movement Spread Multiplier", "sv_movement_spread_multiplier", 0, 5, 2)
            panel:ControlHelp("Controls the spread when moving (default: 1.2)")

            panel:Button("Reset to Defaults", "spread_reset_defaults")
        end)
    end)

    concommand.Add("spread_reset_defaults", function()
        RunConsoleCommand("sv_crouch_spread_multiplier", "0.5")
        RunConsoleCommand("sv_default_spread_multiplier", "1")
        RunConsoleCommand("sv_movement_spread_multiplier", "1.2")
    end)
end