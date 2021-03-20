/**************************************************************
                   Plasma Energy Ammo Entity
https://github.com/buu342/GMod-DeadSpacePlasmaCutter
**************************************************************/

AddCSLuaFile("shared.lua")
include('shared.lua')


/*-----------------------------
    Initialize
    Initializes the entity
-----------------------------*/

function ENT:Initialize()

    -- Setup the model 
    self:SetModel("models/weapons/w_ds1_plasmacutter_mag.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:DrawShadow(true)
    self:SetModelScale(2,0)
    
    -- Initialize physics
    local phys = self.Entity:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end
    
    -- Make sure players can press E on the entity
    if (SERVER) then
        self:SetUseType(SIMPLE_USE)
    end
end


/*-----------------------------
    Use
    Called when the player presses E on the entity
-----------------------------*/

function ENT:Use(activator, caller)

    -- If we're a player, give them ammo
    if (activator:IsPlayer()) then
        activator:GiveAmmo(25, "PlasmaEnergy")
        self:EmitSound("deadspace1/weapons/items/pickup.wav")
        self:Remove()
    end
end