/**************************************************************
                      Laser Hitbox Entity
https://github.com/buu342/GMod-DeadSpacePlasmaCutter
**************************************************************/


AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
-- Make sure we can't spawn this entity randomly
ENT.Spawnable      = false
ENT.AdminSpawnable = false

-- Needed for animations
ENT.AutomaticFrameAdvance = true

-- Hitbox radius
local COLLISION_RADIUS = 3


/*-----------------------------
    Initialize
    Initializes the entity
-----------------------------*/

function ENT:Initialize()

    -- Setup the model (Unused anyway)
    self.Entity:SetModel("models/Gibs/HGIBS.mdl")
    self:DrawShadow(false)
    self:SetNotSolid(true)
    
    -- Initiate cheap physics
    self:PhysicsInitSphere(COLLISION_RADIUS)
    self:SetCollisionBounds(Vector(-COLLISION_RADIUS, -COLLISION_RADIUS, -COLLISION_RADIUS), Vector(COLLISION_RADIUS, COLLISION_RADIUS, COLLISION_RADIUS))
    self.PlacedDecal = false

    -- Make sure it's unaffected by gravity
    self:SetMoveType(MOVETYPE_FLY)
    self:SetMoveCollide(MOVECOLLIDE_FLY_SLIDE)
    
    -- Handle damaging
    if SERVER then
        local dmginfo = nil
        local found = ents.FindInSphere(self:GetPos(), 32)
        
        -- Cycle through all the entities we found
        for i=1, #found do
            
            -- If we found something that isn't another laser hitbox
            if (found[i]:GetClass() != "ent_laserhit") then
                local damage = 15
                
                -- Initialize damageinfo
                dmginfo = DamageInfo()
                dmginfo:SetAttacker(self.Owner)
                dmginfo:SetInflictor(self.Inflictor)
                dmginfo:SetDamageType(DMG_BULLET)
                
                -- Set special settings based on what we hit
                if (found[i]:GetClass() == "npc_zombie" && self.CanSlice) && found[i]:Health()-damage <= 0 && GetConVar("hl2_episodic"):GetInt() == 1 then
                    dmginfo:SetAmmoType(game.GetAmmoID('CombineHeavyCannon'))
                elseif (found[i]:GetClass() == "npc_fastzombie" || (found[i]:GetClass() == "npc_zombie" && self.CanSlice)) && found[i]:Health()-damage <= 0 then
                    dmginfo:SetDamageType(DMG_BLAST)
                    damage = 25
                end
                
                -- Apply damage
                dmginfo:SetDamage(damage)
                found[i]:TakeDamageInfo(dmginfo)
                found[i]:Extinguish()
            end
        end
        
        -- Create an explosion, so that blood and stuff works
        if (dmginfo != nil) then
            util.BlastDamageInfo(dmginfo, self:GetPos(), 32)
        end
    end
    
    -- Remove ourselves after a bit
    timer.Simple(0.2, function() if (IsValid(self) && SERVER) then self:Remove() end end)
end


/*-----------------------------
    Think
    Logic that runs every tick
-----------------------------*/

function ENT:Think()

    -- Place a decal clientside
    if (CLIENT && !self.PlacedDecal) then
    
        -- Create a trace to see if we penetrate something
        local trace = {}
        trace.start = self:GetPos() - Vector(COLLISION_RADIUS, COLLISION_RADIUS, COLLISION_RADIUS)
        trace.endpos = self:GetPos() + Vector(COLLISION_RADIUS, COLLISION_RADIUS, COLLISION_RADIUS)
        local trline = util.TraceLine(trace)
        self.PlacedDecal = true
        
        -- If we hit something valid, then create the decal
        if (trline.Entity != NULL) then 
            util.DecalEx(Material(util.DecalMaterial("FadingScorch")), trline.Entity, trline.HitPos, trline.HitNormal, Color(255,255,255,255), 0.2, 0.2)
        end
    end
end


/*-----------------------------
    RenderOverride
    Overrides rendering on the entity
-----------------------------*/

if SERVER then return end
function ENT:RenderOverride()

    -- Useful for debugging hitboxes. Uncomment to see them
    /*
    local phys = self:GetPhysicsObject()
    local col = COLLISION_RADIUS
    local mins = Vector(-col, -col, -col)
    local maxs = Vector(col, col, coL)
    local pos = self:GetPos()
    local angle = self:GetAngles()
    render.SetMaterial(Material("models/debug/debugwhite"))
    render.DrawWireframeBox(pos, angle, mins, maxs, Color(255,255,255,255), true)
    */
end