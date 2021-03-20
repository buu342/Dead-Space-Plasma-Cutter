/**************************************************************
                   Plasma Energy Ammo Entity
https://github.com/buu342/GMod-DeadSpacePlasmaCutter
**************************************************************/

ENT.Type        = "anim"
ENT.Base        = "base_anim"

-- Basic entity info
ENT.PrintName   = "Plasma Energy"
ENT.Author      = "Buu342"
ENT.Information = "Provies ammunition for the Plasma Cutter"
ENT.Category    = "Dead Space"

-- Allow spawning this entity
ENT.Spawnable      = true
ENT.AdminSpawnable = true


if CLIENT then

    /*-----------------------------
        Draw
        Draws the entity
    -----------------------------*/

    local Icon = "models/deadspace1/weapons/generic/pickup_plasma" 
    local LightPoint = Material('models/deadspace1/weapons/generic/glow2')
    function ENT:Draw()
    
        -- Draw ourselves
        self:DrawModel()
        
        -- Create a little light sprite
        local lightpos = self:GetPos()
        local lightang = self:GetAngles()
        lightpos = lightpos + lightang:Forward()*13.2 + lightang:Right()*0.75 + lightang:Up()*3.8
        render.SetMaterial(LightPoint)
        render.DrawSprite(lightpos, 5, 5, Color(255,255,255))
        
        -- Create a trace to the player
        local tr = util.TraceLine({
            start = self:GetPos()+Vector(0,0,10),
            endpos = LocalPlayer():GetPos()+Vector(0,0,50),
            filter = self
        })
        
        -- If the player is close enough to the plasma energy
        if (LocalPlayer():GetPos():Distance(self:GetPos()) < 96 && tr.Entity && LocalPlayer()) then
        
            -- Allow picking up and play a sound
            if self.CanBePickedUp == false then
                self.CanBePickedUp = true
                self:EmitSound("deadspace1/weapons/items/near.wav")
            end
            
            -- Get the entity's Position
            local pos = self:GetPos()
            local ang = Angle(0, LocalPlayer():EyeAngles().y, 0)
            ang:RotateAroundAxis(ang:Up(), -90)
            ang:RotateAroundAxis(ang:Right(), 0)
            ang:RotateAroundAxis(ang:Forward(), 90)
            pos = pos + ang:Forward() * -30 + ang:Right() * -65 + ang:Up() * 5
            
            -- Draw the ammo info
            cam.Start3D2D(pos, ang, 0.1)
                local TexturedQuadStructure = {
                    texture = surface.GetTextureID(Icon),
                    color    = Color(255,255,255,255),
                    x     = 0,
                    y     = 0,
                    w     = 512,
                    h     = 512
                }
                draw.TexturedQuad(TexturedQuadStructure)
            cam.End3D2D()
        else
            self.CanBePickedUp = false
        end
    end
end