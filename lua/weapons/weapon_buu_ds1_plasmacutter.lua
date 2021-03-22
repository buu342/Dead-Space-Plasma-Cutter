/**************************************************************
                  Dead Space 1 Plasma Cutter
https://github.com/buu342/GMod-DeadSpacePlasmaCutter
**************************************************************/


AddCSLuaFile()
DEFINE_BASECLASS( "weapon_buu_base2" )

-- SWEP info
SWEP.PrintName    = "211-V Plasma Cutter"
SWEP.Purpose      = "Designed and manufactured by Schofield Tools, the 211-V is a tool designed to be used in mining operations. It uses two alignment blades on the side, and three lights on the front, to help the user accurately cut through softer minerals. It uses an internal power source, is compact/light enough to be easily portable, and can be even used one handed.!"
SWEP.Instructions = "Right click to aim, left click to attack. E to rotate."
SWEP.Category     = "Dead Space"

-- Initialize ammo type
game.AddAmmoType({
    name = "PlasmaEnergy",
})

-- Kill icons and ammo name
if CLIENT then
    SWEP.WepSelectIcon = surface.GetTextureID("VGUI/entities/weapon_buu_ds1_plasmacutter")
    killicon.Add("weapon_buu_ds1_plasmacutter", "VGUI/entities/weapon_buu_ds1_plasmacutter", Color(255,255,255))
    language.Add("PlasmaEnergy_ammo", "Plasma Energy")
end

-- Use Buu Base 2
SWEP.Base = "weapon_buu_base2"

-- Set it to the pistol category
SWEP.Slot = 1
SWEP.SlotPos = 0

-- Make the weapon spawnable
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- Model settings
SWEP.ViewModel  = "models/weapons/c_ds1_plasmacutter.mdl"
SWEP.WorldModel = "models/weapons/w_ds1_plasmacutter.mdl"
SWEP.Hold = "revolver"
SWEP.ViewModelFOV = 50

-- Primary fire settings
SWEP.Primary.Sound       = Sound("deadspace1/weapons/plasmacutter/shoot.wav")
SWEP.Primary.Recoil      = 0.6
SWEP.Primary.Damage      = 15
SWEP.Primary.NumShots    = 1
SWEP.Primary.Cone        = 0.0001
SWEP.Primary.ClipSize    = 10
SWEP.Primary.Delay       = 0.7
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic   = false
SWEP.Primary.Ammo        = "PlasmaEnergy"

-- Reloading settings
SWEP.ReloadAmmoTime = 0.8
SWEP.MagModel = "models/weapons/w_ds1_plasmacutter_mag.mdl"
SWEP.MagDropTime = 0.4

-- Laser bones
SWEP.LaserBone1 = "Laser1"
SWEP.LaserBone2 = "Laser2"
SWEP.LaserBone3 = "Laser3"
SWEP.LaserPos = Vector(0, 0, 0)
SWEP.LaserAng = Angle(-3.5, -93.65, 0)

-- Disable crosshair
SWEP.CrosshairType = 0

-- Disable fancy Buu Base features
SWEP.CanIronsight     = false
SWEP.CanSprint        = false
SWEP.CanNearWall      = false
SWEP.CanLadder        = false
SWEP.CanSlide         = false
SWEP.CanSmoke         = false
SWEP.CustomFlashlight = false

-- Overwrite ironsights fully
SWEP.IronsightFOV = -1
SWEP.IronSightsPos = -1
SWEP.IronSightsAng = -1
SWEP.IronsightSway = 0

-- Overwrite running animations
SWEP.RunArmPos   = -1
SWEP.RunArmAngle = -1

-- Useful textures and tables
local LaserBeam  = Material('models/deadspace1/weapons/generic/laser')
local LaserPoint = Material('models/deadspace1/weapons/generic/glow')
local bonesto = {SWEP.LaserBone1, SWEP.LaserBone2, SWEP.LaserBone3}


/*-----------------------------
    SetupDataTables
    Initializes predicted variables
-----------------------------*/

function SWEP:SetupDataTables()
    
    -- Call the Buu Base version of this function
    BaseClass.SetupDataTables(self)
    
    -- Add some new predicted variables
    self:NetworkVar("Int", 0, "Buu_DS_Swing")
    self:NetworkVar("Float", 0, "Buu_DS_SwingTimer")
    self:NetworkVar("Float", 1, "Buu_DS_SwingPunch")
end


/*-----------------------------
    Initialize
    Initializes the weapon
-----------------------------*/

function SWEP:Initialize()

    -- Call the Buu Base version of this function
    BaseClass.Initialize(self)
    
    -- Initialize timers and fire mode
    self:SetBuu_FireMode(0)
    self:SetBuu_DS_Swing(0)
    self:SetBuu_DS_SwingTimer(0)
end


/*-----------------------------
    Deploy
    Called when the weapon is deployed
    @Return Whether to allow switching away from this weapon
-----------------------------*/

function SWEP:Deploy()

    -- Grab the player's movement speed
    self.OriginalWalkSpeed = self.Owner:GetWalkSpeed()
    self.OriginalRunSpeed = self.Owner:GetRunSpeed()
    
    -- Call the Buu Base version of this function
    BaseClass.Deploy(self)
    
    -- Set the idle animation based on the fire mode
    if (self:GetBuu_FireMode() == 0) then
        self:SendWeaponAnim(ACT_VM_IDLE_1)
    else
        self:SendWeaponAnim(ACT_VM_IDLE_2)
    end
    
    -- Allow attacking ASAP
    self:SetNextPrimaryFire(CurTime())
    
    -- Disable flashlight, as the plasma cutter has its own
    if (SERVER && self.Owner:FlashlightIsOn()) then
        self.Owner:Flashlight(false)
    end
end


/*-----------------------------
    Holster
    Called when the weapon is holstered
    @Param  The weapon being holstered to
    @Return Whether to allow holstering
-----------------------------*/

function SWEP:Holster(holsterto)

    -- Cleanup after ourselves
    self:Cleanup()
    
    -- Call the Buu Base version of this function
    return BaseClass.Holster(self, holsterto)
end


/*-----------------------------
    OnRemove
    Called when the weapon is removed
-----------------------------*/

function SWEP:OnRemove()

    -- Cleanup after ourselves
    self:Cleanup()
    
    -- Call the Buu Base version of this function
    BaseClass.OnRemove(self)
end


/*-----------------------------
    PrimaryAttack
    Called when left clicking
-----------------------------*/

function SWEP:PrimaryAttack()
    if (self:GetBuu_Reloading() || self:GetBuu_Sprinting()) then return end
    
    -- If we're aiming
    if (self:GetBuu_Ironsights()) then
        if (self:Clip1() == 0) then return end
        if (self:GetNextPrimaryFire() > CurTime()) then return end

        -- Iterate through the three lasers
        for i=1, 3 do
        
            -- Calculate the hit position of this laser
            local pos = self:CalcHitPos(i)
            local trace = {}
            trace.start = pos - Vector(1, 1, 1)
            trace.endpos = pos + Vector(1, 1, 1)
            local trline = util.TraceLine(trace)
            
            -- Create a spark where we shot
            if (IsFirstTimePredicted() || (SERVER && game.SinglePlayer())) then
                local effectdata = EffectData()
                effectdata:SetOrigin(pos)
                effectdata:SetNormal(trline.HitNormal)
                util.Effect("MetalSpark", effectdata)
            end
            
            -- Create laser hitboxes where we hit
            if (SERVER) then
                local ent = ents.Create("ent_laserhit")
                ent:SetPos(pos)
                ent.Inflictor = self
                ent.Owner = self.Owner
                
                -- If we hit a chest or stomach, and we're horizontal, then allow slicing zombies
                if ((trline.HitGroup == HITGROUP_CHEST || trline.HitGroup == HITGROUP_STOMACH) && self:GetBuu_FireMode() == 1) then
                    ent.CanSlice = true
                end
                
                -- Spawn the hitbox
                ent:Spawn()
                ent:Activate()
            end
        end 
        
        -- Perform thirdperson animations
        self.Owner:SetAnimation(PLAYER_ATTACK1)
        self:ShootEffects()
        
        -- Create a dynamic light (only works for the LocalPlayer)
        if (CLIENT && IsFirstTimePredicted()) then
            local dlight = DynamicLight(self.Owner:EntIndex())
            if (dlight) then
                dlight.pos = self.Owner:GetShootPos()
                dlight.r = 83
                dlight.g = 221
                dlight.b = 205
                dlight.brightness = 2
                dlight.Decay = 1000
                dlight.Size = 256
                dlight.DieTime = CurTime() + 1
            end
        end
        
        -- Tell everyone else we created a dynamic light, so they do too
        if (SERVER) then
            net.Start("Buu_DS_PlasmaLight")
                net.WriteEntity(self)
            net.Broadcast()
        end
        
        -- Start the firing animation
        if (self:GetBuu_FireMode() == 0) then
            self:SendWeaponAnim(ACT_VM_RECOIL1)
        else
            self:SendWeaponAnim(ACT_VM_RECOIL2)
        end
        
        -- Take ammo, and mark that we fired this frame
        self:SetBuu_FireTime(CurTime())
        self:TakePrimaryAmmo(self.Primary.TakeAmmo)
        
        -- Perform viewpunch
        local recoil = self.Primary.Recoil
        self.Owner:ViewPunch(Angle(util.SharedRandom("ViewPunchBuu", -0.5, -2.5)*recoil, util.SharedRandom("ViewPunchBuu", -1, 1)*recoil, 0))
        
        -- Play a sound, and only let the user fire after some time
        self:EmitSound(self.Primary.Sound)  
        self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
        
        -- Tell everyone else how much ammo we have left
        if (SERVER) then
            net.Start("Buu_DS_NetworkClip1")
                net.WriteEntity(self)
                net.WriteInt(self:Clip1(), 32)
            net.Broadcast()
        end
        
        -- Change the owner's view angles permanantly
        if ((game.SinglePlayer() && SERVER) || (!game.SinglePlayer() && CLIENT && IsFirstTimePredicted())) then
            local eyeang = self.Owner:EyeAngles()
            eyeang.pitch = eyeang.pitch - (self.Primary.Delay*0.5)
            eyeang.yaw = eyeang.yaw - (self.Primary.Delay*math.random(-1, 1)*0.25)
            self.Owner:SetEyeAngles(eyeang)
        end
    else
    
        -- Otherwise, perform a melee animation
        self:PerformMelee()
    end
end


/*-----------------------------
    Reload
    Called when the player presses reload
-----------------------------*/

function SWEP:Reload()
    if (self:Clip1() == self:GetMaxClip1()) then return end
    if (self.Owner:GetAmmoCount(self:GetPrimaryAmmoType()) <= 0) then return end
    if (self:GetNextPrimaryFire() > CurTime()) then return end
    
    -- Decide on the animation to play
    local anim
    if (self:GetBuu_Ironsights()) then
        if (self:GetBuu_FireMode() == 0) then
            anim = ACT_VM_RELOAD
            self:SendWorldmodelAnimation("reload1", 0.25)
        else
            anim = ACT_VM_RELOAD2
            self:SendWorldmodelAnimation("reload2", 0.25)
        end
    else
        if (self:GetBuu_FireMode() == 0) then
            anim = ACT_VM_IDLE_DEPLOYED_1
            self:SendWorldmodelAnimation("reload1_idle", 0.25)
        else
            anim = ACT_VM_IDLE_DEPLOYED_2
            self:SendWorldmodelAnimation("reload2_idle", 0.25)
        end
    end
    self.Weapon:SendWeaponAnim(anim)
    
    -- Set timers 
    self:SetBuu_Reloading(true)
    self:SetBuu_GotoIdle(CurTime() + self.Owner:GetViewModel():SequenceDuration())
    self:SetBuu_ReloadAmmoTime(CurTime() + self.Owner:GetViewModel():SequenceDuration()*self.ReloadAmmoTime)
    self:SetNextPrimaryFire(self:GetBuu_GotoIdle())
    self:SetBuu_MagDropTime(CurTime()+self.MagDropTime)
    
    -- Third person animation
    self:SetHoldType("revolver")
    self:SetWeaponHoldType(self:GetHoldType())
    self.Owner:SetAnimation(PLAYER_RELOAD)
    
    -- Slow the player down as he's reloading
    self.Owner:SetWalkSpeed(100)
    self.Owner:SetRunSpeed(100)
end


/*-----------------------------
    Think
    Logic that runs every frame
-----------------------------*/

function SWEP:Think()

    -- Deplay sometimes doesn't get called clientside. This fixes that
    if (self.OriginalWalkSpeed == nil) then
        self:Deploy()
    end

    -- Handle holdtypes
    if (SERVER || IsFirstTimePredicted()) then
        if (self:GetBuu_Ironsights() || self:GetBuu_Reloading()) then
            self:SetHoldType("revolver")
            self:SetWeaponHoldType(self:GetHoldType())
        elseif (self:GetBuu_DS_SwingTimer() != 0 && self:GetBuu_DS_SwingTimer() > CurTime()) then
            self:SetHoldType("melee")
            self:SetWeaponHoldType(self:GetHoldType())
        else
            self:SetHoldType("normal")
            self:SetWeaponHoldType(self:GetHoldType())
        end
    end
    
    -- Handle melee damage
    if (self:GetBuu_DS_SwingPunch() < CurTime() && self:GetBuu_DS_SwingPunch() != 0) then
        self:DoMeleeDamage()
    end
    
    -- If the swinging timer finished, reset the swing type
    if (self:GetBuu_DS_SwingTimer() != 0 && self:GetBuu_DS_SwingTimer() < CurTime()) then
        self:SetBuu_DS_Swing(0)
        self:SetBuu_DS_SwingTimer(0)
    end
    
    -- Handle swapping fire modes
    if (self:GetBuu_Ironsights() && self:GetNextPrimaryFire() < CurTime()) then
        if (self.Owner:KeyPressed(IN_USE)) then
            if (self:GetBuu_FireMode() == 0) then
                self:SendWeaponAnim(ACT_VM_HITRIGHT)
                self:SendWorldmodelAnimation("rotate", 2)
                self:SetBuu_FireMode(1)
            else
                self:SendWeaponAnim(ACT_VM_HITLEFT)
                self:SendWorldmodelAnimation("rotate_back", 2)
                self:SetBuu_FireMode(0)
            end
            self:SetNextPrimaryFire(CurTime() + 0.3)
            self:SetBuu_StateTimer(self:GetNextPrimaryFire()) -- Used to disable third person animation lerping
        end
    end
    
    -- Handle third person shooting animations
    if (self:GetBuu_FireTime() != 0) then
        self:SetBuu_FireTime(0)
        if (self:GetBuu_FireMode() == 0) then
            self:SendWorldmodelAnimation("shoot1", 0.5)
        else
            self:SendWorldmodelAnimation("shoot2", 0.5)
        end
    end
    
    -- Handle ironsight state
    self:HandleIronsights()
    
    -- Handle sprinting state
    self:HandleSprinting()
    
    -- Handle idle state
    self:HandleIdle()
    
    -- Handle when you receive ammo during a reload
    self:HandleReloadAmmo()

    -- Handle magazine drops
    self:HandleMagDropping()
end


/*-----------------------------
    PerformMelee
    Handles melee attack logic
-----------------------------*/

function SWEP:PerformMelee()

    -- If the weapon hasn't been swung yet, or we're mid swing
    if (self:GetBuu_DS_SwingTimer() == 0 || (self:GetBuu_DS_SwingTimer()-0.5 < CurTime() && !(self:GetBuu_DS_SwingTimer()-0.35 < CurTime()))) then
    
        -- Set the swing state to 1 if it's 0
        if self:GetBuu_DS_Swing() == 0 then
            self:SetBuu_DS_Swing(1)
        end
        
        -- Decide on the animation based on the swing state
        if (self:GetBuu_DS_Swing() == 1) then
            if (self:GetBuu_FireMode() == 0) then
                self:SendWeaponAnim(ACT_VM_MISSLEFT)
            else
                self:SendWeaponAnim(ACT_VM_MISSLEFT2)
            end
        else
            if (self:GetBuu_FireMode() == 0) then
                self:SendWeaponAnim(ACT_VM_MISSRIGHT)
            else
                self:SendWeaponAnim(ACT_VM_MISSRIGHT2)
            end
        end
        
        -- Set timers and the new swing state
        self:SetBuu_DS_SwingPunch(CurTime() + 0.5)
        self:SetBuu_DS_SwingTimer(CurTime() + 1.2)
        self:SetBuu_DS_Swing(1+self:GetBuu_DS_Swing()%2)
    end
end


/*-----------------------------
    DoMeleeDamage
    Handles melee attack damage
-----------------------------*/

function SWEP:DoMeleeDamage()

    -- Reset the damage timer
    self:SetBuu_DS_SwingPunch(0)

    -- Viewpunch based on attack animation
    if self:GetBuu_DS_Swing() == 2 then
        self.Owner:ViewPunch(Angle(10,7,0))
    else
        self.Owner:ViewPunch(Angle(-3,-10,0))
    end
    
    -- Play the attack animation in thirdperson
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    -- Enable lag compensation
    self.Owner:LagCompensation(true)

    -- Create a quick trace to see if we have anything in the way
    local tr = util.TraceLine({
        start = self.Owner:GetShootPos(),
        endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector()*48,
        filter = self.Owner,
        mask = MASK_SHOT_HULL
    })

    -- If we did, perform a trace hull to check the bounding box we hit
    if (!IsValid(tr.Entity)) then
        tr = util.TraceHull({
            start = self.Owner:GetShootPos(),
            endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector()*48,
            filter = self.Owner,
            mins = Vector(-10, -10, -8),
            maxs = Vector(10, 10, 8),
            mask = MASK_SHOT_HULL
        })
    end

    -- Apply damage if we hit something
    if (IsValid(tr.Entity)) then
        if (SERVER) then
            local rightforce = 5000
            local upforce = 2000
            
            -- Initialize a DamageInfo object
            local dmginfo = DamageInfo()
            dmginfo:SetAttacker(self.Owner)
            dmginfo:SetInflictor(self)
            dmginfo:SetDamage(15)
            
            -- Set the force depending on the swing we did
            if (self:GetBuu_DS_Swing() == 2) then
                rightforce = -5000
                upfoce = -3000
            end
            
            -- Damage the entity
            dmginfo:SetDamageForce(self.Owner:GetRight()*rightforce + self.Owner:GetUp()*upforce)
            tr.Entity:TakeDamageInfo(dmginfo)
            tr.Entity:EmitSound(Sound("Flesh.ImpactHard"), 50)
        end
    end

    -- Apply some force to the hit entity
    if (SERVER && IsValid(tr.Entity)) then
        local phys = tr.Entity:GetPhysicsObject()
        if (IsValid(phys)) then
            phys:ApplyForceOffset(self.Owner:GetAimVector()*80*phys:GetMass(), tr.HitPos)
        end
    end

    -- Disable lag compensation
    self.Owner:LagCompensation(false)
end


/*-----------------------------
    HandleIronsights
    Handles ironsight logic
-----------------------------*/

function SWEP:HandleIronsights()

    -- If we can attack
    if (self:GetNextPrimaryFire() < CurTime() && self:GetBuu_DS_SwingTimer() < CurTime()) then
    
        -- If we are holding right click and on the ground
        if (self.Owner:KeyDown(IN_ATTACK2) && self.Owner:IsOnGround()) then
            if (!self:GetBuu_Ironsights()) then
                if (self:GetBuu_FireMode() == 0) then
                    self:SendWeaponAnim(ACT_VM_DEPLOY_1)
                    self:SendWorldmodelAnimation("aim_in1", 1)
                else
                    self:SendWeaponAnim(ACT_VM_DEPLOY_2)
                    self:SendWorldmodelAnimation("aim_in2", 1)
                end
                self.Owner:SetWalkSpeed(100)
                self.Owner:SetRunSpeed(100)
                self:SetNextPrimaryFire(CurTime() + 0.5)
                self:SetBuu_TimeToScope(CurTime()+0.15)
                self:SetBuu_Ironsights(true)
                self:SetBuu_Sprinting(false)
            end
        else
            if self:GetBuu_Ironsights() == true then
                if self:GetBuu_FireMode() == 0 then
                    self:SendWeaponAnim(ACT_VM_UNDEPLOY_1)
                    self:SendWorldmodelAnimation("aim_out1", 1)
                else
                    self:SendWeaponAnim(ACT_VM_UNDEPLOY_2)
                    self:SendWorldmodelAnimation("aim_out2", 1)
                end
                self.Owner:SetWalkSpeed(self.OriginalWalkSpeed)
                self.Owner:SetRunSpeed(self.OriginalRunSpeed)
                self:SetNextPrimaryFire(CurTime() + 0.5)
                self:SetBuu_Ironsights(false)
            end
            self:SetBuu_TimeToScope(0)
        end
    end
end


/*-----------------------------
    HandleSprinting
    Handles sprinting logic
-----------------------------*/

function SWEP:HandleSprinting()
    
    -- If we're not ironsighting or swinging
    if (!self:GetBuu_Ironsights() && self:GetNextPrimaryFire() < CurTime() && self:GetBuu_DS_SwingTimer() == 0) then
        
        -- And we're sprinting
        if (self.Owner:KeyDown(IN_SPEED) && !self:GetBuu_Sprinting() && !self:GetBuu_Reloading() && self.Owner:GetVelocity():Length() > self.Owner:GetWalkSpeed() && !self.Owner:KeyDown(IN_DUCK) && self.Owner:IsOnGround() && (self.Owner:KeyDown(IN_FORWARD))) then
            
            -- Play the sprinting animation
            self:SetBuu_Sprinting(true)
            if (self:GetBuu_FireMode() == 0) then
                self:SendWeaponAnim(ACT_VM_HITCENTER)
            else
                self:SendWeaponAnim(ACT_VM_HITCENTER2)
            end
        elseif (self:GetBuu_Sprinting() && (!self.Owner:KeyDown(IN_SPEED) || !self.Owner:IsOnGround() || self:GetBuu_Reloading() || !self.Owner:KeyDown(IN_FORWARD) || self.Owner:KeyDown(IN_DUCK))) then
            
            -- Go back to the idle animation
            self:SetBuu_Sprinting(false)
            if (!self:GetBuu_Reloading()) then
                if (self:GetBuu_FireMode() == 0) then
                    self:SendWeaponAnim(ACT_VM_IDLE_1)
                else
                    self:SendWeaponAnim(ACT_VM_IDLE_2)
                end
            end
        end
    end
end


/*-----------------------------
    HandleIdle
    Handles going into idle state
-----------------------------*/

function SWEP:HandleIdle()

    -- If the timer for the idle state is done
    if (self:GetBuu_GotoIdle() != 0 && self:GetBuu_GotoIdle() < CurTime()) then
        self:SetBuu_GotoIdle(0)
        
        -- If we were reloading
        if (self:GetBuu_Reloading()) then
        
            -- If we're ironsighting, go back to aiming animation, otherwise reset the speed
            if (self:GetBuu_Ironsights()) then
                self.Owner:SetAnimation(PLAYER_ATTACK1)
            else
                self.Owner:SetWalkSpeed(self.OriginalWalkSpeed)
                self.Owner:SetRunSpeed(self.OriginalRunSpeed)
            end
            
            -- Stop reloading
            self:SetBuu_Reloading(false)
        end
    end
end


/*-----------------------------
    HandleReloadAmmo
    Handles when ammo is given during a reload
-----------------------------*/

function SWEP:HandleReloadAmmo()
    
    -- Call the Buu Base version of this function
    local clip = self:Clip1()
    BaseClass.HandleReloadAmmo(self)
    
    -- The other players don't get Clip1 information properly, so we need to network that...
    if (clip != self:Clip1()) then
        if (SERVER) then
            net.Start("Buu_DS_NetworkClip1")
                net.WriteEntity(self)
                net.WriteInt(self:Clip1(), 32)
            net.Broadcast()
        end
    end
end


/*-----------------------------
    SendWorldmodelAnimation
    Sends an animation to the worldmodel
    @Param The sequence name
    @Param The speed to play it at
-----------------------------*/

function SWEP:SendWorldmodelAnimation(anim, speed)

    -- Network this to everyone if we're the server
    if (SERVER) then
        net.Start("Buu_DS_BroadcastAnim")
            net.WriteEntity(self)
            net.WriteString(anim)
            net.WriteFloat(speed)
        net.Broadcast()
    end
    
    -- Initialize the animation info
    if (self.WorldModelEnt != nil) then
        self.WorldModelEnt:ResetSequence(self.WorldModelEnt:LookupSequence(anim))
        self.WorldModelAnim = 0
        self.WorldModelAnimTime = 1/speed
    end
end


/*-----------------------------
    MuzzleEffect
    Creates a muzzleflash effect
    @Param The weapon to attach the muzzle to
-----------------------------*/

function SWEP:MuzzleEffect(wep)
    local fx = EffectData()
    if (!IsValid(wep)) then return end
    fx:SetOrigin(wep:GetAttachment(wep:LookupAttachment("1")).Pos)
    fx:SetEntity(wep)
    fx:SetStart(wep.Owner:GetShootPos())
    fx:SetNormal(wep.Owner:GetAimVector())
    fx:SetAttachment(1)
    fx:SetScale(10)
    util.Effect("cball_bounce", fx)
    util.Effect("ChopperMuzzleFlash", fx)    
end


/*-----------------------------
    CalcHitPos
    Calculates the laser hit position
    @Param   Which laser
    @Param   Override the FireMode check
    @Returns The position where the laser hit
-----------------------------*/

function SWEP:CalcHitPos(i, mode)
    local tr = {
        start = self.Owner:GetShootPos(),
        endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector()*32768,
        filter = self.Owner
    }

    local ang = self.Owner:GetAimVector():Angle()
    local right = 0
    local up = 0
    local distance = self.Owner:GetShootPos():Distance(util.TraceLine(tr).HitPos)
    
    if (mode == 1 || (mode == nil && self:GetBuu_FireMode() == 1)) then
        if (i == 1) then
            right = 4
        elseif (i == 3) then
            right = -4
        end
    else
        if (i == 1) then
            up = 4
        elseif (i == 3) then
            up = -4
        end        
    end
    
    if (distance < 128) then
        up = up - (1-distance/128)*21
        right = right + (1-distance/128)*21
    end
    
    tr.start = tr.start + ang:Right()*right + ang:Up()*up
    return util.TraceLine(tr).HitPos 
end


/*-----------------------------
    Cleanup
    Fixes anything due to suddenly being removed, like
    flashlight and player speed
-----------------------------*/

function SWEP:Cleanup()
    if (self.WorldModelEnt != nil) then
        self.WorldModelEnt:Remove()
        self.WorldModelEnt = nil
    end
    if (IsValid(self.Owner)) then
        if (IsValid(self.Owner:GetViewModel()) && self.Owner:GetViewModel().FlashLight != nil) then
            self.Owner:GetViewModel().FlashLight:Remove()
            self.Owner:GetViewModel().FlashLight = nil
        end
        if (self.OriginalWalkSpeed != nil) then
            self.Owner:SetWalkSpeed(self.OriginalWalkSpeed)
            self.Owner:SetRunSpeed(self.OriginalRunSpeed)
        end
    end
end


if (CLIENT) then

    /*-----------------------------
        DrawWorldModel
        Draws the worldmodel
    -----------------------------*/

    function SWEP:DrawWorldModel()

        -- If we're not being used by a player, then draw the worldmodel properly
        if (self.Owner == nil || !IsValid(self.Owner) || self.Owner:GetActiveWeapon() != self) then
            self:DrawModel()
            return
        end
        
        -- Initialize worldmodel animation info
        if (self.WorldModelAnim == nil) then
            self.WorldModelAnim = 0
            self.WorldModelAnimTime = 0
        end
        
        -- Advance the animation over time
        if (self.WorldModelAnim < 1) then
            self.WorldModelAnim = math.Clamp(self.WorldModelAnim + (FrameTime())/self.WorldModelAnimTime, 0, 1)
        end
        
        -- If the worldmodel entity doesn't exist, create it
        if (self.WorldModelEnt == nil) then
            self.WorldModelEnt = ClientsideModel(self.WorldModel)
            self.WorldModelEnt:SetParent(self.Owner, 0)
            self.WorldModelEnt:AddEffects(EF_BONEMERGE)
            if (self:GetBuu_FireMode() == 1) then
                self.WorldModelEnt:ResetSequence(self.WorldModelEnt:LookupSequence("idle2"))
            end
        end
        
        -- Set the worldmodel entity's animation cycle and draw it
        self.WorldModelEnt:SetCycle(self.WorldModelAnim)
        self.WorldModelEnt:DrawModel()
        
        -- Draw lasers if we're ironsighting and not reloading
        if (self:GetBuu_Ironsights() && !self:GetBuu_Reloading()) then
        
            -- Iterate through the 3 lasers
            for i=1, 3 do
                local pos, ang = self:GetBoneOrientation(self.WorldModelEnt, bonesto[i])
                
                -- Make sure the positions exist
                if (pos == nil || ang == nil) then return end
                
                -- Correct the bone angles
                ang:RotateAroundAxis(ang:Up(), -90)
                ang:RotateAroundAxis(ang:Right(), 0)
                ang:RotateAroundAxis(ang:Forward(), 0)
                ang = ang:Forward()

                -- Create a trace to see where the laser hits
                local tr = {
                    start = pos,
                    endpos = pos + ang*8192,
                    filter = self.Owner,
                }
                trace = util.TraceLine(tr)
                
                -- If the tracer hit something
                if (util.PointContents(trace.HitPos) != CONTENTS_SOLID) then
                    local pointpos
                    
                    -- Calculate the laser hitting position based on our weapon state
                    if (self:GetNextPrimaryFire() > CurTime() && self:GetBuu_StateTimer() < CurTime()) then
                        pointpos = Lerp(1-(self:GetNextPrimaryFire()-CurTime()), trace.HitPos, self:CalcHitPos(i))
                    elseif (self:GetBuu_StateTimer() > CurTime()) then
                        pointpos = LerpVector(1-(self:GetBuu_StateTimer()-CurTime())/0.3, self:CalcHitPos(i, (self:GetBuu_FireMode()+1)%2), self:CalcHitPos(i))
                    else
                        pointpos = self:CalcHitPos(i)
                    end
                    
                    -- Draw the laser and the point
                    render.SetMaterial(LaserBeam)
                    render.DrawBeam(pos, pointpos, 0.5, 0, 0.99, Color(255, 255, 255))
                    render.SetMaterial(LaserPoint)
                    render.DrawSprite(pointpos, 6, 6, Color(255, 255, 255, 255))
                end
            end
            
            -- Render the ammo count
            self:RenderAmmoCount(self, self)
        end
    end
    
    
    /*-----------------------------
        FireAnimationEvent
        Allows for overriding of viewmodel events
        @Param  The position of the effect
        @Param  The Angle of the effect
        @Param  The event that ocurred
        @Return Whether to override the effect or not
    -----------------------------*/

    function SWEP:FireAnimationEvent(pos, ang, event)
    
        -- If we have a muzzleflash effect
        if (event == 5001 || event == 21 || event == 22) then 
            if !IsValid(self.Owner) then return false end
            
            -- Emit our custom muzzleflash instead
            self:MuzzleEffect(self.Owner:GetViewModel())
            return true
        end    
    end


    /*-----------------------------
        RenderAmmoCount
        Renders the ammo on the weapon model
        @Param The weapon
        @Param The model
    -----------------------------*/

    local AmmoHud = "models/deadspace1/weapons/generic/ammo"
    function SWEP:RenderAmmoCount(weapon, model)
        local pos3, ang3 = weapon:GetBoneOrientation(model, "Mag")
        local drawpos = pos3 + ang3:Forward() * 1.5 + ang3:Right() * -3 + ang3:Up() * 1
        ang3:RotateAroundAxis(ang3:Up(), 0)
        ang3:RotateAroundAxis(ang3:Right(), 180)
        ang3:RotateAroundAxis(ang3:Forward(), -90)
        
        local col = Color( 83, 221, 205, 200 )
        if weapon:Clip1() == 0 then
            col = Color( 255, 0, 0, 200 )
        elseif (weapon:Clip1()/weapon:GetMaxClip1()) <= 0.2 then
            col = Color( 255, 106, 0, 200 )
        end
        
        cam.Start3D2D(drawpos, ang3, 0.1)
            local TexturedQuadStructure = {
                texture = surface.GetTextureID(AmmoHud),
                color    = col,
                x     = 0,
                y     = 0.5,
                w     = 32,
                h     = 16
            }
            draw.TexturedQuad(TexturedQuadStructure)
            draw.SimpleText(weapon:Clip1(), "DebugFixed", 15.5, 0.1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        cam.End3D2D()
    end


    /*-----------------------------
        PlasmaCutterLights_VM
        Renders the light on the weapon viewmodel
    -----------------------------*/

    local function PlasmaCutterLights_VM()
        local ply = LocalPlayer()
        
        -- Ensure the player is alive
        if (IsValid(ply)) then
        
            -- Ensure we are using the plasmacutter and aiming
            local wep = ply:GetActiveWeapon()
            if (IsValid(wep) && wep:GetClass() == "weapon_buu_ds1_plasmacutter" && wep:GetBuu_Ironsights() && !wep:GetBuu_Reloading()) then

                -- Get the light color based on our magazine
                local col = Color( 83, 221, 205, 200 )
                if (ply:GetActiveWeapon():Clip1() == 0) then
                    col = Color( 255, 0, 0, 200 )
                elseif ((ply:GetActiveWeapon():Clip1()/ply:GetActiveWeapon():GetMaxClip1()) <= 0.2) then
                    col = Color( 255, 106, 0, 200 )
                end
                
                -- Correct the light position
                local pos, ang = ply:GetActiveWeapon():GetBoneOrientation( ply:GetViewModel(), "Mag" )
                local drawpos = pos + ang:Forward()*1.5 + ang:Right()*(-3) + ang:Up()*5
                ang:RotateAroundAxis(ang:Up(), 0)
                ang:RotateAroundAxis(ang:Right(), 180)
                ang:RotateAroundAxis(ang:Forward(), -90)
                
                -- Create a dynamic light
                local dlight = DynamicLight( ply:EntIndex() )
                if (dlight) then
                    dlight.pos = drawpos
                    dlight.r = col.r
                    dlight.g = col.g
                    dlight.b = col.b
                    dlight.brightness = 0.01
                    dlight.Decay = 1024
                    dlight.Size = 32
                    dlight.DieTime = CurTime() + 2
                end
            end
        end
    end
    hook.Add("PreDrawViewModel", "PlasmaCutterLightsVM", PlasmaCutterLights_VM)


    /*-----------------------------
        ViewModelDrawn
        Code that runs after the viewmodel is drawn
        Used for laser and flashlight handling in firstperson
        @Param The viewmodel
    -----------------------------*/

    SWEP.lastlaserposition = {Vector(0,0,0), Vector(0,0,0), Vector(0,0,0)}
    SWEP.pointpos = {Vector(0,0,0), Vector(0,0,0), Vector(0,0,0)}
    function SWEP:ViewModelDrawn(vm)
        
        -- If we aren't aiming with the weapon, or we're in third person
        if (!self:GetBuu_Ironsights() || self:GetBuu_Reloading() || GetViewEntity() != self.Owner) then 
        
            -- Remove the viewmodel flashlight
            if (vm.FlashLight != nil) then
                vm.FlashLight:Remove()
                vm.FlashLight = nil
            end
            
            -- Reset the laser positions
            for i=1, 3 do
                self.lastlaserposition[i] = -1
                self.pointpos[i] = -1
            end
            return
        end
        
        -- If we're aiming
        if (self:GetBuu_Ironsights() && self.Owner:GetViewModel( 0 ) == vm) then
        
            -- Iterate through the three lasers           
            for i=1, 3 do
                local bonepos, boneang = self:GetBoneOrientation(vm, bonesto[i]) 
                
                -- Make sure we have a valid position
                if bonepos == nil || boneang == nil then return end
                
                -- Correct the laser position and angles
                bonepos = bonepos + boneang:Right() * self.LaserPos.x + boneang:Up() * self.LaserPos.y + boneang:Forward() * self.LaserPos.z
                boneang:RotateAroundAxis(boneang:Right(), self.LaserAng.p)
                boneang:RotateAroundAxis(boneang:Up(), self.LaserAng.y)
                boneang:RotateAroundAxis(boneang:Forward(), self.LaserAng.r)
                boneang = boneang:Forward()

                -- Check if we hit something
                local mainbone = self:GetBoneOrientation(vm, bonesto[2])
                local mybone = self:GetBoneOrientation(vm, bonesto[i])
                local tr = {
                    start = self.Owner:GetShootPos() + (mybone - mainbone),
                    endpos = self.Owner:GetShootPos() + (mybone - mainbone) + self.Owner:GetAimVector() * 8192,
                    filter = self.Owner,
                    mask = MASK_SHOT_HULL
                }
                trace = util.TraceLine(tr)
                local original_hitpos = trace.HitPos
                local tr = {
                    start = bonepos,
                    endpos = bonepos + boneang*8192,
                    filter = self.Owner
                }
                trace = util.TraceLine(tr)
                
                -- If we hit something valid
                if (util.PointContents(trace.HitPos) != CONTENTS_SOLID) then
                
                    -- Calculate the distance
                    dist = tr.start:Distance(trace.HitPos)
                    dist = 1-dist/128
                    if (tr.start:Distance(trace.HitPos) > 128) then
                        dist = 0
                    end
                    
                    -- Calculate the final hit position 
                    local final_hitpos = original_hitpos*(1-dist) + trace.HitPos*(dist)
                    local Tr = self.Owner:GetEyeTrace()
                    if (Tr.Hit and Tr.HitPos:Distance(self.Owner:GetShootPos()) < 33) then
                        final_hitpos = bonepos
                    end
                    
                    -- Render the laser, if we have a valid old position
                    if (self.lastlaserposition[i] != -1) then
                        render.SetMaterial(LaserBeam)
                        render.DrawBeam(bonepos + boneang, final_hitpos, 0.5, 0, 0.99, Color(255,255,255))
                        render.DrawBeam(final_hitpos, self.lastlaserposition[i], 5, 0, 1, Color(255,255,255))
                        render.SetMaterial(LaserPoint)
                        render.SetMaterial(LaserPoint)
                        render.DrawSprite(final_hitpos, 5, 5, Color(255,255,255))
                    end
                    
                    -- Store the position for next time
                    self.lastlaserposition[i] = final_hitpos
                end
            end
        end
        
        -- If the flashlight is enabled
        if (self:GetBuu_Ironsights() && self.Owner:GetViewModel(0) == vm && !self:GetBuu_Reloading()) then
        
            -- Make sure we can attach to the muzzle
            local attach = self:HandleMuzzleAttachmentHelper(vm)
            if (attach == nil) then return end
            
            -- Create the flashlight if it doesn't exist yet
            local muzzle = vm:GetAttachment(vm:LookupAttachment(attach))
            if (vm.FlashLight == nil) then
                vm.FlashLight = ProjectedTexture()
                vm.FlashLight:SetTexture("effects/flashlight001")
                vm.FlashLight:SetFarZ(712)
                vm.FlashLight:SetFOV(50)
            end
            
            -- Update its position and angles
            vm.FlashLight:SetPos(muzzle.Pos)
            vm.FlashLight:SetAngles(muzzle.Ang)
            vm.FlashLight:Update()
        end
        
        -- Render the ammo count
        self:RenderAmmoCount(self, vm)
    end
    
    
    /*-----------------------------
        Buu_DS_PlasmaLight
        Emits the plasma light
    -----------------------------*/
    
    local function Buu_DS_PlasmaLight()
        local wep = net.ReadEntity()
        
        -- If we're not in singleplayer, and we received this net message
        if (!IsValid(wep)) then return end
        if (wep.Owner == LocalPlayer() && !game.SinglePlayer()) then 
        
            -- Render the muzzle if in third person
            if (LocalPlayer():ShouldDrawLocalPlayer()) then
                wep:MuzzleEffect(wep)
            end
            return 
        end
        
        -- Create the dynamic light
        local dlight = DynamicLight(wep.Owner:EntIndex())
        if (dlight) then
            dlight.pos = wep.Owner:GetShootPos()
            dlight.r = 83
            dlight.g = 221
            dlight.b = 205
            dlight.brightness = 2
            dlight.Decay = 1000
            dlight.Size = 256
            dlight.DieTime = CurTime() + 1
        end
        
        -- Create the muzzleflash
        wep:MuzzleEffect(wep)
    end
    net.Receive("Buu_DS_PlasmaLight", Buu_DS_PlasmaLight)


    /*-----------------------------
        Buu_DS_BroadcastAnim
        Set the animation on the worldmodel
    -----------------------------*/

    local function Buu_DS_BroadcastAnim()
        local wep = net.ReadEntity()
        local anim = net.ReadString()
        local speed = net.ReadFloat()
        
        -- If we're not ourselves, and there's a valud worldmodel
        if (!IsValid(wep) || wep.Owner == LocalPlayer() && !game.SinglePlayer()) then return end
        if (wep.WorldModelEnt == nil) then return end
        
        -- Set the variables from what we read
        wep.WorldModelAnim = 0
        wep.WorldModelAnimTime = 1/speed
        wep.WorldModelEnt:ResetSequence(wep.WorldModelEnt:LookupSequence(anim))
    end
    net.Receive("Buu_DS_BroadcastAnim", Buu_DS_BroadcastAnim)

    /*-----------------------------
        Buu_DS_NetworkClip1
        Receives the value of Clip1 from other players
    -----------------------------*/

    local function Buu_DS_NetworkClip1()
        local wep = net.ReadEntity()
        local clip = net.ReadInt(32)
        if (!IsValid(wep) || wep.Owner == LocalPlayer()) then return end
        wep:SetClip1(clip)
    end
    net.Receive("Buu_DS_NetworkClip1", Buu_DS_NetworkClip1)


    /*-----------------------------
        Buu_PlasmaCutter_ThirdPersonRendering
        Handles rendering the laser and flashlight in third person
    -----------------------------*/

    local function Buu_PlasmaCutter_ThirdPersonRendering()
        
        -- Check all players
        for k, v in pairs(player.GetAll()) do
            local wep = v:GetActiveWeapon()
            
            -- Check if we're holding a buu weapon and we're not in firstperson
            if (IsValid(wep) && wep:GetClass() == "weapon_buu_ds1_plasmacutter" && (v != LocalPlayer() || v:ShouldDrawLocalPlayer())) then
                        
                -- Remove the firstperson flashlight if it exists
                if (v:GetViewModel().FlashLight != nil) then
                    v:GetViewModel().FlashLight:Remove()
                    v:GetViewModel().FlashLight = nil
                end
                
                -- If we're using the flashlight
                if (wep:GetBuu_Ironsights() && !wep:GetBuu_Reloading()) then
                    local pos, ang = wep:GetBoneOrientation(wep.WorldModelEnt, "Laser2")
                    
                    -- If the positions are invalid, stop
                    if (pos == nil || ang == nil) then return end
                    ang:RotateAroundAxis(ang:Up(), -90)
                    ang:RotateAroundAxis(ang:Right(), 0)
                    ang:RotateAroundAxis(ang:Forward(), 0)
                    
                    -- Create the flashlight if it doesn't exist yet
                    if (v.FlashlightEntPC == nil) then
                        local lamp = ProjectedTexture()
                        v.FlashlightEntPC = lamp
                        v.FlashlightEntPC:SetTexture("effects/flashlight001")
                        v.FlashlightEntPC:SetFarZ(712)
                        v.FlashlightEntPC:SetFOV(50)
                    end
                    
                    -- Update its position and angles
                    v.FlashlightEntPC:SetPos(pos) 
                    v.FlashlightEntPC:SetAngles(ang)
                    v.FlashlightEntPC:Update()
                elseif (v.FlashlightEntPC != nil) then
                    v.FlashlightEntPC:Remove()
                    v.FlashlightEntPC = nil       
                end
            end
            
            -- If we're not in thirdperson, remove the flashlight entity
            if (IsValid(wep) && !(wep:GetClass() == "weapon_buu_ds1_plasmacutter" && (v != LocalPlayer() || v:ShouldDrawLocalPlayer())) && v.FlashlightEntPC != nil) then
                v.FlashlightEntPC:Remove()
                v.FlashlightEntPC = nil
            end
        end
    end
    hook.Add("PostDrawTranslucentRenderables", "Buu_PlasmaCutter_ThirdPersonRendering", Buu_PlasmaCutter_ThirdPersonRendering) 
end


if SERVER then
    util.AddNetworkString("Buu_DS_PlasmaLight")
    util.AddNetworkString("Buu_DS_BroadcastAnim")
    util.AddNetworkString("Buu_DS_NetworkClip1")
    
    
    /*-----------------------------
        Buu_PlasmaCutter_DisableFlashlight
        Stops flashlight serverside if using the plasma cutter
        @param The player
        @param Whether it was requested to be turned on or off
    -----------------------------*/
    
    function Buu_PlasmaCutter_DisableFlashlight(ply, tostate)
    
        -- If we're holding the plasma cutter, disable flashlight
        if (ply:GetActiveWeapon() != nil && IsValid(ply:GetActiveWeapon()) && ply:GetActiveWeapon():GetClass() == "weapon_buu_ds1_plasmacutter") then
            return !tostate
        end
    end
    hook.Add("PlayerSwitchFlashlight", "Buu_PlasmaCutter_DisableFlashlight", Buu_PlasmaCutter_DisableFlashlight)
end