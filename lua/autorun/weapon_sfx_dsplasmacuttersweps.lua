/**************************************************************
                      Model Sound Effects
https://github.com/buu342/GMod-DeadSpacePlasmaCutter
**************************************************************/


if SERVER then return end


/*================ Dead Space 1 Plasma Cutter ===============*/

//{
local soundData = {
    name       = "Weapon_DSpace1_PCutter.Rotate" ,
    channel    = CHAN_USER_BASE+1,
    volume     = 0.1,
    soundlevel = 100,
    pitchstart = 100,
    pitchend   = 100,
    sound      = "deadspace1/weapons/plasmacutter/rotate.wav"
}
sound.Add(soundData)

local soundData = {
    name       = "Weapon_DSpace1_PCutter.Swing1" ,
    channel    = CHAN_USER_BASE+1,
    volume     = 0.05,
    soundlevel = 100,
    pitchstart = 100,
    pitchend   = 100,
    sound      = "deadspace1/weapons/plasmacutter/swing1.wav"
}
sound.Add(soundData)

local soundData = {
    name       = "Weapon_DSpace1_PCutter.Swing2" ,
    channel    = CHAN_USER_BASE+1,
    volume     = 0.05,
    soundlevel = 100,
    pitchstart = 100,
    pitchend   = 100,
    sound      = "deadspace1/weapons/plasmacutter/swing2.wav"
}
sound.Add(soundData)

local soundData = {
    name       = "Weapon_DSpace1_PCutter.AimIn" ,
    channel    = CHAN_USER_BASE+1,
    volume     = 0.05,
    soundlevel = 100,
    pitchstart = 100,
    pitchend   = 100,
    sound      = "deadspace1/weapons/plasmacutter/aimin.wav"
}
sound.Add(soundData)

local soundData = {
    name       = "Weapon_DSpace1_PCutter.AimOut" ,
    channel    = CHAN_USER_BASE+1,
    volume     = 0.05,
    soundlevel = 100,
    pitchstart = 100,
    pitchend   = 100,
    sound      = "deadspace1/weapons/plasmacutter/aimout.wav"
}
sound.Add(soundData)

local soundData = {
    name       = "Weapon_DSpace1_PCutter.Magout" ,
    channel    = CHAN_USER_BASE+1,
    volume     = 0.05,
    soundlevel = 100,
    pitchstart = 100,
    pitchend   = 100,
    sound      = "deadspace1/weapons/plasmacutter/magout.wav"
}
sound.Add(soundData)

local soundData = {
    name       = "Weapon_DSpace1_PCutter.Magin" ,
    channel    = CHAN_USER_BASE+1,
    volume     = 0.05,
    soundlevel = 100,
    pitchstart = 100,
    pitchend   = 100,
    sound      = "deadspace1/weapons/plasmacutter/magin.wav"
}
sound.Add(soundData)

local soundData = {
    name       = "Weapon_DSpace1_PCutter.Move1" ,
    channel    = CHAN_USER_BASE+1,
    volume     = 0.1,
    soundlevel = 100,
    pitchstart = 100,
    pitchend   = 100,
    sound      = "deadspace1/weapons/plasmacutter/move1.wav"
}
sound.Add(soundData)

local soundData = {
    name       = "Weapon_DSpace1_PCutter.Move2" ,
    channel    = CHAN_USER_BASE+1,
    volume     = 0.05,
    soundlevel = 100,
    pitchstart = 100,
    pitchend   = 100,
    sound      = "deadspace1/weapons/plasmacutter/move2.wav"
}
sound.Add(soundData)

local soundData = {
    name       = "Weapon_DSpace1_PCutter.Move3" ,
    channel    = CHAN_USER_BASE+1,
    volume     = 0.1,
    soundlevel = 100,
    pitchstart = 100,
    pitchend   = 100,
    sound      = "deadspace1/weapons/plasmacutter/move3.wav"
}
sound.Add(soundData)
//}