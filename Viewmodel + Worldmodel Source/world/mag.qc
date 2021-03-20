// Created by Crowbar 0.19.0.0

$modelname "weapons/w_ds1_plasmacutter_mag.mdl"

$bodygroup "studio"
{
	studio "mag.smd"
}

$cdmaterials "models\DeadSpace1\Weapons\PlasmaCutter"

$surfaceprop "weapon"

$contents "solid"

$sequence "idle" "mag.smd" {
	fps 30
	"ACT_VM_IDLE" 1
	loop
}

$collisionmodel "mag.smd"
{
	$mass 8
	$inertia 1
	$damping 0
	$rotdamping 0
}