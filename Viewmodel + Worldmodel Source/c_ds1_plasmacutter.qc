// Created by Crowbar 0.12.0.0

$modelname "weapons\c_ds1_plasmacutter.mdl"

$bodygroup "studio"
{
	studio "reference.smd"
}

$proceduralbones c_arms_vrd.vrd

$cdmaterials "models\DeadSpace1\Weapons\PlasmaCutter"

$attachment "1" "Laser2" 0.00 0.00 0.00 rotate -0 -90 0

$illumposition 3.995 -9.538 -6.393

$sequence "idle1" "anims\idle1.smd" {
	fps 30
	"ACT_VM_IDLE_1" 1
	loop
	node "Ready"
}

$sequence "idle2" "anims\idle2.smd" {
	fps 30
	"ACT_VM_IDLE_2" 1
	loop
	node "Ready"
}

$sequence "run1" "anims\run1.smd" {
	fps 30
	"ACT_VM_HITCENTER" 1
	loop
	snap
	node "Ready"
}

$sequence "run2" "anims\run2.smd" {
	fps 30
	"ACT_VM_HITCENTER2" 1
	loop
	snap
	node "Ready"
}

$sequence "rotate" "anims\rotate.smd" {
	fps 30
	"ACT_VM_HITRIGHT" 1
	snap
	node "Ready"
    { event 5004 0 "Weapon_DSpace1_PCutter.Rotate" }
}

$sequence "swing1_1" "anims\swing1_1.smd" {
	fps 30
	"ACT_VM_MISSLEFT" 1
	snap
	node "Ready"
    { event 5004 11 "Weapon_DSpace1_PCutter.Swing1" }
}

$sequence "swing1_2" "anims\swing1_2.smd" {
	fps 30
	"ACT_VM_MISSLEFT2" 1
	snap
	node "Ready"
    { event 5004 11 "Weapon_DSpace1_PCutter.Swing1" }
}

$sequence "swing2_1" "anims\swing2_1.smd" {
	fps 30
	"ACT_VM_MISSRIGHT" 1
	snap
	node "Ready"
    { event 5004 11 "Weapon_DSpace1_PCutter.Swing2" }
}

$sequence "swing2_2" "anims\swing2_2.smd" {
	fps 30
	"ACT_VM_MISSRIGHT2" 1
	snap
	node "Ready"
    { event 5004 11 "Weapon_DSpace1_PCutter.Swing2" }
}

$sequence "rotate_back" "anims\rotate_back.smd" {
	fps 30
	"ACT_VM_HITLEFT" 1
	snap
	node "Ready"
    { event 5004 0 "Weapon_DSpace1_PCutter.Rotate" }
}

$sequence "shoot1" "anims\shoot1.smd" {
	fps 30
	"ACT_VM_RECOIL1" 1
	snap
	node "Ready"
    { event 5001 0 "1" }
}

$sequence "shoot2" "anims\shoot2.smd" {
	fps 30
	"ACT_VM_RECOIL2" 1
	snap
	node "Ready"
    { event 5001 0 "1" }
}

$sequence "reload1" "anims\reload1.smd" {
	fps 30
	"ACT_VM_RELOAD" 1
	snap
	node "Ready"
	{ event 5004 0 "Weapon_DSpace1_PCutter.Move1" }
    { event 5004 12 "Weapon_DSpace1_PCutter.Magout" }
	{ event 5004 22 "Weapon_DSpace1_PCutter.Move2" }
	{ event 5004 39 "Weapon_DSpace1_PCutter.Magin" }
	{ event 5004 51 "Weapon_DSpace1_PCutter.Move3" }
}

$sequence "reload2" "anims\reload2.smd" {
	fps 30
	"ACT_VM_RELOAD2" 1
	snap
	node "Ready"
	{ event 5004 0 "Weapon_DSpace1_PCutter.Move1" }
    { event 5004 12 "Weapon_DSpace1_PCutter.Magout" }
	{ event 5004 22 "Weapon_DSpace1_PCutter.Move2" }
	{ event 5004 39 "Weapon_DSpace1_PCutter.Magin" }
	{ event 5004 51 "Weapon_DSpace1_PCutter.Move3" }
}

$sequence "reload1_idle" "anims\reload1_idle.smd" {
	fps 30
	"ACT_VM_IDLE_DEPLOYED_1" 1
	snap
	node "Ready"
	{ event 5004 0 "Weapon_DSpace1_PCutter.Move1" }
    { event 5004 12 "Weapon_DSpace1_PCutter.Magout" }
	{ event 5004 22 "Weapon_DSpace1_PCutter.Move2" }
	{ event 5004 39 "Weapon_DSpace1_PCutter.Magin" }
	{ event 5004 51 "Weapon_DSpace1_PCutter.Move3" }
}

$sequence "reload2_idle" "anims\reload2_idle.smd" {
	fps 30
	"ACT_VM_IDLE_DEPLOYED_2" 1
	snap
	node "Ready"
	{ event 5004 0 "Weapon_DSpace1_PCutter.Move1" }
    { event 5004 12 "Weapon_DSpace1_PCutter.Magout" }
	{ event 5004 22 "Weapon_DSpace1_PCutter.Move2" }
	{ event 5004 39 "Weapon_DSpace1_PCutter.Magin" }
	{ event 5004 51 "Weapon_DSpace1_PCutter.Move3" }
}

$sequence "aim_in1" "anims\aim_in1.smd" {
	fps 60
	"ACT_VM_DEPLOY_1" 1
	snap
	node "Ready"
    { event 5004 0 "Weapon_DSpace1_PCutter.AimIn" }
}

$sequence "aim_in2" "anims\aim_in2.smd" {
	fps 60
	"ACT_VM_DEPLOY_2" 1
	snap
	node "Ready"
    { event 5004 0 "Weapon_DSpace1_PCutter.AimIn" }
}

$sequence "aim_out1" "anims\aim_out1.smd" {
	fps 60
	"ACT_VM_UNDEPLOY_1" 1
	snap
	node "Ready"
    { event 5004 0 "Weapon_DSpace1_PCutter.AimOut" }
}

$sequence "aim_out2" "anims\aim_out2.smd" {
	fps 60
	"ACT_VM_UNDEPLOY_2" 1
	snap
	node "Ready"
    { event 5004 0 "Weapon_DSpace1_PCutter.AimOut" }
}

$bonemerge "ValveBiped.Bip01_Spine4"
$bonemerge "ValveBiped.Bip01_L_Clavicle"
$bonemerge "ValveBiped.Bip01_L_UpperArm"
$bonemerge "ValveBiped.Bip01_L_Forearm"
$bonemerge "ValveBiped.Bip01_L_Hand"
$bonemerge "ValveBiped.Bip01_L_Wrist"
$bonemerge "ValveBiped.Bip01_L_Finger4"
$bonemerge "ValveBiped.Bip01_L_Finger41"
$bonemerge "ValveBiped.Bip01_L_Finger42"
$bonemerge "ValveBiped.Bip01_L_Finger3"
$bonemerge "ValveBiped.Bip01_L_Finger31"
$bonemerge "ValveBiped.Bip01_L_Finger32"
$bonemerge "ValveBiped.Bip01_L_Finger2"
$bonemerge "ValveBiped.Bip01_L_Finger21"
$bonemerge "ValveBiped.Bip01_L_Finger22"
$bonemerge "ValveBiped.Bip01_L_Finger1"
$bonemerge "ValveBiped.Bip01_L_Finger11"
$bonemerge "ValveBiped.Bip01_L_Finger12"
$bonemerge "ValveBiped.Bip01_L_Finger0"
$bonemerge "ValveBiped.Bip01_L_Finger01"
$bonemerge "ValveBiped.Bip01_L_Finger02"
$bonemerge "ValveBiped.Bip01_R_Clavicle"
$bonemerge "ValveBiped.Bip01_R_UpperArm"
$bonemerge "ValveBiped.Bip01_R_Forearm"
$bonemerge "ValveBiped.Bip01_R_Hand"
$bonemerge "ValveBiped.Bip01_R_Wrist"
$bonemerge "ValveBiped.Bip01_R_Finger4"
$bonemerge "ValveBiped.Bip01_R_Finger41"
$bonemerge "ValveBiped.Bip01_R_Finger42"
$bonemerge "ValveBiped.Bip01_R_Finger3"
$bonemerge "ValveBiped.Bip01_R_Finger31"
$bonemerge "ValveBiped.Bip01_R_Finger32"
$bonemerge "ValveBiped.Bip01_R_Finger2"
$bonemerge "ValveBiped.Bip01_R_Finger21"
$bonemerge "ValveBiped.Bip01_R_Finger22"
$bonemerge "ValveBiped.Bip01_R_Finger1"
$bonemerge "ValveBiped.Bip01_R_Finger11"
$bonemerge "ValveBiped.Bip01_R_Finger12"
$bonemerge "ValveBiped.Bip01_R_Finger0"
$bonemerge "ValveBiped.Bip01_R_Finger01"
$bonemerge "ValveBiped.Bip01_R_Finger02"