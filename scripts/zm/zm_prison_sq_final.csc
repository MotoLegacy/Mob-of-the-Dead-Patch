#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\audio_shared;
#using scripts\shared\util_shared;
#using scripts\shared\postfx_shared;

#using scripts\zm\_filter;

#using scripts\zm\_zm_magicbox_prison;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

function autoexec init()
{
    clientfield::register( "toplayer", "player_listening_to_headset", VERSION_SHIP, 1,	"int",	&sq_ambientroom, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function sq_ambientroom( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    SetUIModelValue( CreateUIModel( GetUIModelForController( localClientNum ), "listeningtoheadset" ), newVal );

    if (newval == 1) {
        ForceAmbientRoom("sndHealth_LastStand");
    } else {
        ForceAmbientRoom("");
    }
}