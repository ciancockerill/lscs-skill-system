local force = {}
force.PrintName = "Cool Force Power"
force.Author = "YOU"
force.Description = "force template"
force.id = "myforcepower" -- lowercase only

--force.EntityBase = "lscs_force_base" -- change base entity?
--force.Spawnable = false  -- uncomment to unlist in q-menu
--force.AdminOnly = true -- make this admin only on q-menu?
--force.IconOverride = "lscs/ui/noicon.png" -- custom icon path

--[[
force.OnClk =  function( ply, TIME )
	print(TIME)
end
]]--


force.Equip = function( ply )
	print("i got equipped")
end

force.UnEquip = function( ply )
	print("i got unequipped :(")
end

force.StartUse = function( ply )
    ply:SetVelocity(ply:GetAimVector() * 512 + Vector( 0, 0, 512 ) )
	ply:EmitSound("npc/combine_gunship/ping_search.wav")

	LSCS:PlayVCDSequence( ply, "gesture_signal_halt", 0 ) 
end

force.StopUse = function( ply )
	-- called when the force power key is released
end

LSCS:RegisterForce( force )