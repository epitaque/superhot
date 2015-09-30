"use strict";

function WrapFunction(name)
{
	return function() { $.Msg("WrapFunction " + name + ": ", Game[name]);  Game[name](); };
}

Game.AddCommand("+KeyPressUp", WrapFunction("OnPressUp"), "", 0);
Game.AddCommand("+KeyPressLeft", WrapFunction("OnPressLeft"), "", 0);
Game.AddCommand("+KeyPressDown", WrapFunction("OnPressDown"), "", 0);
Game.AddCommand("+KeyPressRight", WrapFunction("OnPressRight"), "", 0);

Game.AddCommand("-KeyPressUp", WrapFunction("OnReleaseUp"), "", 0);
Game.AddCommand("-KeyPressLeft", WrapFunction("OnReleaseLeft"), "", 0);
Game.AddCommand("-KeyPressDown", WrapFunction("OnReleaseDown"), "", 0);
Game.AddCommand("-KeyPressRight", WrapFunction("OnReleaseRight"), "", 0);

(function()
{
	$.Msg("[SuperHot] superhot_keybind_register.js loaded."); 
})();
