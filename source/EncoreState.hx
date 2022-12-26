package;

import flixel.util.FlxTimer;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import sys.FileSystem;
import flixel.addons.effects.FlxSkewedSprite;


#if windows
import Discord.DiscordClient;
#end

using StringTools;

class EncoreState extends MusicBeatState // REWRITE FREEPLAY!?!?!? HELL YEA!!!!!
{
	var whiteshit:FlxSprite;

	var curSelected:Int = 0;

	var charArray:Array<String> = ["too-slow-encore", "you-cant-run-encore", "triple-trouble-encore"];
	var charUnlocked:Array<String> = ["too-slow-encore", "you-cant-run-encore", "triple-trouble-encore"];

	var boxgrp:FlxTypedSpriteGroup<FlxSprite>;

	var bg:FlxSprite;

	var cdman:Bool = true;

	var fuck:Int = 0;

	var songtext:FlxText;
	var prevsongtext:FlxText;

	override function create()
	{
		whiteshit = new FlxSprite().makeGraphic(1280, 720, FlxColor.WHITE);
		whiteshit.alpha = 0;

		bg = new FlxSprite().loadGraphic(Paths.image('backgroundlool'));
		bg.screenCenter();
		bg.setGraphicSize(1280, 720);
		add(bg);

		boxgrp = new FlxTypedSpriteGroup<FlxSprite>();
		charArray[curSelected];
		songtext = new FlxText(0, FlxG.height - 100, StringTools.replace(charArray[curSelected], "-", " "), 25);
		songtext.setFormat("Sonic CD Menu Font Regular", 25, FlxColor.fromRGB(255, 255, 255));
		songtext.x = (FlxG.width / 2) - (25 / 2 * charArray[curSelected].length);
		add(songtext);

		FlxG.log.add('sexo: ' + (songtext.width / charArray[curSelected].length));

		prevsongtext = new FlxText(0, FlxG.height - 100, StringTools.replace(charArray[curSelected], "-", " "), 25);
		prevsongtext.x = (FlxG.width / 2) - (25 / 2 * charArray[curSelected].length);
		prevsongtext.setFormat("Sonic CD Menu Font Regular", 25, FlxColor.fromRGB(255, 255, 255));
		
		add(prevsongtext);

		for (i in 0...charArray.length)
		{
			if (charArray.contains(charArray[i])) // ok cool
			{
				var box:FlxSkewedSprite = new FlxSkewedSprite(i * 780, 0);
				box.loadGraphic(Paths.image('FreeBox'));
				boxgrp.add(box);
				box.ID = i;
				box.setGraphicSize(Std.int(box.width / 1));

				FlxG.log.add('searching for ' + charArray[i].toLowerCase() + '.png in assets/images/fpstuff');

				if (charUnlocked.contains(charArray[i]))
				{
					if (FileSystem.exists('assets/images/fpstuff/' + charArray[i].toLowerCase() + '.png'))
					{
						FlxG.log.add(charArray[i] + ' found.');
						var char:FlxSkewedSprite = new FlxSkewedSprite(i * 780, 0);
						char.loadGraphic(Paths.image('fpstuff/' + charArray[i].toLowerCase()));
						boxgrp.add(char);
						char.ID = i;
						char.setGraphicSize(Std.int(box.width / 1));
					}
					else
					{
						FlxG.log.add(charArray[i] + ' not found. Applied placeholder.');
						var char:FlxSkewedSprite = new FlxSkewedSprite(i * 780, 0);
						char.loadGraphic(Paths.image('fpstuff/placeholder'));
						boxgrp.add(char);
						char.ID = i;
						char.setGraphicSize(Std.int(box.width / 1));
					}
				}
			}
		}
		/*
		if (FlxG.save.data.charArray.length != 0)
		{
			for (i in 0...charArray.length)
			{

				if (FlxG.save.data.charArray.contains(charArray[fuck]))
				{
			
					FlxG.log.add(charArray[i] + ' found');
	
					var box:FlxSprite = new FlxSprite(fuck * 780, 0).loadGraphic(Paths.image('FreeBox'));
					boxgrp.add(box);

					var char:FlxSprite = new FlxSprite(fuck * 780, 0).loadGraphic(Paths.image('fpstuff/' + charArray[fuck].toLowerCase()));
					boxgrp.add(char);

					var daStatic:FlxSprite = new FlxSprite();		
					daStatic.frames = Paths.getSparrowAtlas('daSTAT');	
					daStatic.alpha = 0.2;	
					daStatic.setGraphicSize(620, 465);			
					daStatic.setPosition((fuck * 780) + 440, 211);	
					daStatic.animation.addByPrefix('static','staticFLASH', 24, true);			
					boxgrp.add(daStatic);
					daStatic.animation.play('static');

					fuck += 1;
				}
				else 
				{
					charArray.remove(charArray[fuck]);
				}
				
			}
		}
		*/
		
		add(boxgrp);

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Main Menu", "Choosing in Encore");
		#end

		add(whiteshit);

		super.create();
	}



	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A;
		var downP = FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D;
		var accepted = controls.ACCEPT;
		
		
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
		}

		if (cdman)
		{
			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}
		}
		

		
		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}
		
		
		if (accepted && cdman && charArray[0] != 'lol')
		{
			cdman = false;

			switch (charArray[curSelected]) // Some charts don't include -hard in their file name so i decided to get focken lazy.
			{
				default:
					PlayState.SONG = Song.loadFromJson(charArray[curSelected].toLowerCase() + '', charArray[curSelected].toLowerCase());
			}

			PlayState.storyDifficulty = 2;
			PlayState.storyWeek = 1;
			FlxTween.tween(whiteshit, {alpha: 1}, 0.4);
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			PlayStateChangeables.nocheese = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}
		
	}

	
	function changeSelection(change:Int = 0)
	{
		if (change == 1 && curSelected != charArray.length - 1) 
		{
			cdman = false;
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			FlxTween.tween(boxgrp ,{x: boxgrp.x - 780}, 0.2, {ease: FlxEase.expoOut, onComplete: function(sus:FlxTween)
				{
					cdman = true;
				}
			});
			
		}
		else if (change == -1 && curSelected != 0) 
		{
			cdman = false;
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			FlxTween.tween(boxgrp ,{x: boxgrp.x + 780}, 0.2, {ease: FlxEase.expoOut, onComplete: function(sus:FlxTween)
				{
					cdman = true;
				}
			});

		}
		if ((change == 1 && curSelected != charArray.length - 1) || (change == -1 && curSelected > 0)) // This is a.
		{
			songtext.alpha = 0; 
			songtext.text = StringTools.replace(charArray[curSelected + change], "-", " ");
			FlxTween.tween(songtext ,{alpha: 1, x: (FlxG.width / 2) - (25 / 2 * charArray[curSelected + change].length)}, 0.2, {ease: FlxEase.expoOut});
			FlxTween.tween(prevsongtext ,{alpha: 0, x: (FlxG.width / 2) - (25 / 2 * charArray[curSelected + change].length)}, 0.2, {ease: FlxEase.expoOut});
		}

		curSelected += change;
		if (curSelected < 0) curSelected = 0;
		else if (curSelected > charArray.length - 1) curSelected = charArray.length - 1;
	}
}