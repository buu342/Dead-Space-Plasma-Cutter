// Created by Crowbar 0.19.0.0

$modelname "weapons/w_ds1_plasmacutter.mdl"

$bodygroup "studio"
{
	studio "reference.smd"
}

$bodygroup "mag"
{
	studio "mag.smd"
    blank
}


$cdmaterials "models\DeadSpace1\Weapons\PlasmaCutter"

$attachment "1" "Laser2" 0.00 0.00 0.00 rotate -0 -90 0

$surfaceprop "weapon"

$contents "solid"

$Sequence "idle1" "anims/idle1.smd"{
	activity "ACT_VM_IDLE" 1
	fps 30
	loop
    snap
	node "Ready"
}

$sequence "idle2" "anims\idle2.smd" {
	fps 30
	"ACT_VM_IDLE_2" 1
	loop
    snap
	node "Ready"
}

$Sequence "shoot1" {
	"anims/shoot1.smd"
	{ event 3002 0 "" }
	{ event 5001 0 "1" }
	fps 30
    snap
	node "Ready"
}

$Sequence "shoot2" {
	"anims/shoot2.smd"
	{ event 3002 0 "lefthand" }
	{ event 5001 0 "1" }
	fps 30
    snap
	node "Ready"
}

$Sequence "rotate" {
	"anims/rotate.smd"
	fps 30
    snap
	node "Ready"
    "ACT_VM_HITRIGHT" 1
    { event 5004 0 "Weapon_DSpace1_PCutter.Rotate" }
}

$Sequence "rotate_back" {
	"anims/rotate_back.smd"
	fps 30
    snap
	node "Ready"
    "ACT_VM_HITRIGHT" 1
    { event 5004 0 "Weapon_DSpace1_PCutter.Rotate" }
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

$collisionmodel "collision.smd"
{
	$mass 8
	$inertia 1
	$damping 0
	$rotdamping 0
}