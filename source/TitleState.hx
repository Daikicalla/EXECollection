package;

import flixel.graphics.FlxGraphic;
import sys.FileSystem;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var bg:FlxSprite;
	var logoBlBUMP:FlxSprite;
	var titleText:FlxSprite;
	var blackScreen:FlxSprite;

	override function create():Void
	{
		// Flixel saves your volume automatically.
		if (FlxG.save.data.volume != null)
		{
			FlxG.sound.volume = FlxG.save.data.volume;
		}

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		PlayerSettings.init();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		Highscore.load();

		StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		FlxG.save.data.storyProgress = 3;

		FlxG.mouse.visible = false;
		FlxTransitionableState.defaultTransIn = SonicTransitionSubstate;
		FlxTransitionableState.defaultTransOut = SonicTransitionSubstate;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		#if FREEPLAY
		FlxTransitionableState.skipNextTransOut=true;
		FlxTransitionableState.skipNextTransIn=true;
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		FlxTransitionableState.skipNextTransOut=true;
		FlxTransitionableState.skipNextTransIn=true;
		MusicBeatState.switchState(new ChartingState());
		#elseif MENU
		FlxTransitionableState.skipNextTransOut=true;
		FlxTransitionableState.skipNextTransIn=true;
		MusicBeatState.switchState(new EncoreState());
		#else
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add(function(exitCode)
			{
				DiscordClient.shutdown();
			});
			#end
		new FlxTimer().start(0.1, (function(tmr:FlxTimer)
		{
			startIntro();
		}));
		#end
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		if (!transitioning && skippedIntro)
		{
			if (pressedEnter)
			{
				FlxG.camera.flash(FlxColor.RED, 0.2);
				FlxG.sound.play(Paths.sound('menumomentclick', 'exe'));
				FlxG.sound.play(Paths.sound('menulaugh', 'exe'));

				titleText.animation.play('press');

				FlxTween.tween(blackScreen, {alpha: 1}, 4);

				transitioning = true;

				new FlxTimer().start(4, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());
				});
			}
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();
	}

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(5, 0, 0.7);
		}

		Conductor.changeBPM(190);
		persistentUpdate = true;

		bg = new FlxSprite(0, 0);
		bg.frames = Paths.getSparrowAtlas('NewTitleMenuBG');
		bg.animation.addByPrefix('idle', "TitleMenuSSBG instance 1", 24);
		bg.animation.play('idle');
		bg.alpha = .75;
		bg.scale.x = 3;
		bg.scale.y = 3;
		bg.antialiasing = true;
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		logoBlBUMP = new FlxSprite(0, -50);
		logoBlBUMP.loadGraphic(Paths.image('logo'));
		logoBlBUMP.antialiasing = ClientPrefs.globalAntialiasing;
		logoBlBUMP.scale.x = .8;
		logoBlBUMP.scale.y = .8;
		logoBlBUMP.screenCenter(X);
		add(logoBlBUMP);

		titleText = new FlxSprite(0, 0);
		titleText.frames = Paths.getSparrowAtlas('titleEnterNEW');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin instance 1", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED instance 1", 24, false);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter();
		add(titleText);

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackScreen);

		FlxG.sound.play(Paths.sound('TitleLaugh'), 1, false, null, false, function()
		{
			skipIntro();
		});
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.sound.play(Paths.sound('showMoment', 'shared'), .4);
			FlxG.camera.flash(FlxColor.RED, 2);
			blackScreen.alpha = 0;
			skippedIntro = true;
		}
	}
}