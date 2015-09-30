"use strict";

var ISPRESSED_UP, ISPRESSED_DOWN, ISPRESSED_RIGHT, ISPRESSED_LEFT
var localHeroIndex;
var stopped;

Game.OnPressUp = function() { $.Msg("[SuperHot] OnPressUp"); ISPRESSED_UP = true; }
Game.OnPressDown = function() { $.Msg("[SuperHot] OnPressDown"); ISPRESSED_DOWN = true;}
Game.OnPressRight = function() { $.Msg("[SuperHot] OnPressRight"); ISPRESSED_RIGHT = true; }
Game.OnPressLeft = function() { $.Msg("[SuperHot] OnPressLeft"); ISPRESSED_LEFT = true; }

Game.OnReleaseUp = function() { $.Msg("[SuperHot] OnReleaseUp"); ISPRESSED_UP = false; }
Game.OnReleaseDown = function() { $.Msg("[SuperHot] OnReleaseDown"); ISPRESSED_DOWN = false; }
Game.OnReleaseRight = function() { $.Msg("[SuperHot] OnReleaseRight"); ISPRESSED_RIGHT = false; }
Game.OnReleaseLeft = function() { $.Msg("[SuperHot] OnReleaseLeft"); ISPRESSED_LEFT = false; }

function Move()
{
	var pos = Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ));
	var horizontal = 0;
	if(ISPRESSED_RIGHT == true && ISPRESSED_LEFT == false)
	{
		horizontal = 30;
	}
	if(ISPRESSED_RIGHT == false && ISPRESSED_LEFT == true)
	{
		horizontal = -30;
	}

	var vertical = 0;
	if(ISPRESSED_UP == true && ISPRESSED_DOWN == false)
	{
		vertical = 30;
	}
	if(ISPRESSED_UP == false && ISPRESSED_DOWN == true)
	{
		vertical = -30;
	}
	var order = 
	{
		OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position : [horizontal + pos[0], vertical + pos[1], 0],
		Queue : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
		ShowEffects : false
	};

	if(vertical != 0 || horizontal != 0)
	{
		stopped = false;
		Game.PrepareUnitOrders( order );
	}
	else if(stopped == false)
	{
		var stoporder = 
		{
			OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_STOP,
			Queue : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
		};
		stopped = true;
		Game.PrepareUnitOrders( stoporder );
	}

	$.Schedule(1/30, Move);
}

(function()
{
	$.Msg("[SuperHot] superhot_keybind_function loaded."); 
	$.Schedule(1, Move);	
})();
