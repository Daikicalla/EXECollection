package;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import editors.MasterEditorMenu;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2';

	var curSelected:Int = 0;

	var xval:Int = 585;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var soundCooldown:Bool = true;

	var optionShit:Array<String> = [
		'story_mode',
		'encore',
		'freeplay',
		'sound_test',
		'options',
		'patch_notes'
	];

	public static var firstStart:Bool = true;

	public static var finishedFunnyMove:Bool = false;

	var bgdesat:FlxSprite;
	var camFollow:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if windows
		DiscordClient.changePresence("In the Main Menu", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		
		FlxG.sound.playMusic(Paths.music('storymodemenumusic'));
		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		persistentUpdate = persistentDraw = true;
		
		var bg:FlxSprite = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('MainMenuAnim');
		bg.animation.addByPrefix('idle', 'BG instance', 24);
		bg.animation.play('idle', true);
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		bgdesat = new FlxSprite(-80).loadGraphic(Paths.image('backgroundlool2'));
		bgdesat.scrollFactor.x = 0;
		bgdesat.scrollFactor.y = 0;
		bgdesat.setGraphicSize(Std.int(bgdesat.width * .5));
		bgdesat.updateHitbox();
		bgdesat.screenCenter();
		bgdesat.visible = false;
		bgdesat.antialiasing = true;
		bgdesat.color = 0xFFfd719b;
		add(bgdesat);
		// bgdesat.scrollFactor.set();

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(-500, (i * 100) + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.addByPrefix('lock', optionShit[i] + " locked", 24);
			if (optionShit[i] == 'extras') {
				//menuItem.color = FlxColor.fromHSL(menuItem.color.hue, menuItem.color.saturation, 0.2, 1);
				menuItem.animation.play('lock');
				menuItem.animation.addByPrefix('idle', optionShit[i] + " locked", 24);
			}
			else
			{
				menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
				menuItem.animation.play('idle');
			}

			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 5) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();

			
			if (firstStart)
				FlxTween.tween(menuItem,{x: xval},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween)
					{
						if(i == optionShit.length - 1)
						{
							finishedFunnyMove = true;
							changeItem();
						}
					}});
			else
			{
				menuItem.x = xval;
				finishedFunnyMove = true;
				changeItem();
			}
			xval = xval + 70;
		}

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		var dataerase:FlxText = new FlxText(FlxG.width - 300, FlxG.height - 18 * 2, 300, "Hold DEL to erase ALL data (this doesn't include ALL options)", 3);
		dataerase.scrollFactor.set();
		dataerase.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(dataerase);

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.DELETE)
		{
			var urmom = 0;
			new FlxTimer().start(0.1, function(hello:FlxTimer)
			{
				urmom += 1;
				if (urmom == 20)
				{
					FlxG.save.data.storyProgress = 0; // lol.
					FlxG.save.data.soundTestUnlocked = false;
					FlxG.save.data.songArray = [];
					FlxG.switchState(new MainMenuState());
				}
				if (FlxG.keys.pressed.DELETE)
				{
					hello.reset();
				}
			});
		}

		if (!selectedSomethin && finishedFunnyMove)
		{
			if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
			{
				
				if (optionShit[curSelected] == 'extras')
				{
					soundCooldown = false;
					FlxG.sound.play(Paths.sound('deniedMOMENT'));
					camera.shake(0.03,0.03);
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						soundCooldown = true;
					});
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
					if (curSelected != spr.ID)
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];
								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'encore':
										MusicBeatState.switchState(new EncoreState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'sound_test':
										MusicBeatState.switchState(new SoundTestState());
									case 'options':
										MusicBeatState.switchState(new options.OptionsState());
									case 'patch_notes':
										MusicBeatState.switchState(new PatchNotesState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}
		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			var daChoice:String = optionShit[curSelected];
			if(daChoice == 'extras')
			{
				spr.animation.play('lock');
			}
			spr.animation.play('idle');
			/*
			if (huh != 0)
			{
				FlxTween.cancelTweensOf(spr);
			}
			FlxTween.tween(spr, {x: 100 + ((curSelected * -1 + spr.ID + 1) * 220), y: 40 + ((curSelected * -1 + spr.ID + 1) * 140)}, 0.2);
			*/

			if (spr.ID == curSelected) //&& finishedFunnyMove)
			{
				if(daChoice == 'extras'){
					spr.animation.play('lock');
				}
				else
				spr.animation.play('selected');
				// camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
