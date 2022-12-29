package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxTimer;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxSprite>;
	var grpMenuShit2:FlxTypedGroup<FlxSprite>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var camThing:FlxCamera;
	var coolDown:Bool = true;

	var grayButton:FlxSprite;

	var topPause:FlxSprite;
	var bottomPause:FlxSprite;

	public static var transCamera:FlxCamera;

	public static var songName:String = '';

	public function new(x:Float, y:Float)
	{

		camThing = new FlxCamera();
		camThing.bgColor.alpha = 0;
		FlxG.cameras.add(camThing);
		super();

		FlxG.sound.play(Paths.sound("pause"));

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		topPause = new FlxSprite(-1000, 0).loadGraphic(Paths.image("pauseStuff/pauseTop"));
		add(topPause);
		FlxTween.tween(topPause, {x: 0}, 0.2, {ease: FlxEase.quadOut});

		bottomPause = new FlxSprite(1280, 33).loadGraphic(Paths.image('pauseStuff/bottomPanel'));
		FlxTween.tween(bottomPause, {x: 589}, 0.2, {ease: FlxEase.quadOut});
		add(bottomPause);

		grayButton = new FlxSprite().loadGraphic(Paths.image('pauseStuff/graybut'));
		grayButton.x = FlxG.width - 400 + 480;
		grayButton.y = FlxG.height / 2 + 70;
		FlxTween.tween(grayButton, {x: grayButton.x - 480}, 0.2, {ease: FlxEase.quadOut});
		add(grayButton);

		grpMenuShit = new FlxTypedGroup<FlxSprite>();
		add(grpMenuShit);

		grpMenuShit2 = new FlxTypedGroup<FlxSprite>();
		add(grpMenuShit2);

		for (i in 0...menuItems.length)
		{
			var songText:FlxSprite = new FlxSprite(FlxG.width + 400 + 80 * i, FlxG.height / 2 + 70 + 100 * i);
			songText.loadGraphic(Paths.image("pauseStuff/blackbut"));
			songText.x += (i + 1) * 480;
			songText.ID = i;
			FlxTween.tween(songText, {x: songText.x - 480 * (i + 1)}, 0.2, {ease: FlxEase.quadOut});
			grpMenuShit.add(songText);
			var actualText:FlxSprite = new FlxSprite(songText.x + 25, songText.y + 25).loadGraphic(Paths.image(StringTools.replace("pauseStuff/" + menuItems[i], " ", "")));
			actualText.ID = i;
			actualText.x += (i + 1) * 480;
			actualText.y = FlxG.height / 2 + 70 + 100 * i + 5;
			//if (!practiceMode){
			FlxTween.tween(actualText, {x: FlxG.width - 400 - 80 * i + 25}, 0.2, {ease: FlxEase.quadOut});
			grpMenuShit2.add(actualText);
		}

		coolDown = false;
		new FlxTimer().start(0.2, function(lol:FlxTimer)
		{
			coolDown = true;
			changeSelection();
		});

		cameras = [camThing];
	}

	override function update(elapsed:Float)
	{
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		super.update(elapsed);

		if (coolDown)
		{
			if (upP)
			{
				changeSelection(-1);
			}

			if (downP)
			{
				changeSelection(1);
			}

			if (accepted)
			{
				var daSelected:String = menuItems[curSelected];

				switch (daSelected)
				{
					case "Resume":
						// coolDown = false;
						FlxG.sound.play(Paths.sound("unpause"));
						grpMenuShit.forEach(function(item:FlxSprite)
						{
							FlxTween.tween(item, {x: item.x + 480 * (item.ID + 1)}, 0.2, {ease: FlxEase.quadOut});
						});
						grpMenuShit2.forEach(function(item2:FlxSprite)
						{
							FlxTween.tween(item2, {x: item2.x + 480 * (item2.ID + 1)}, 0.2, {ease: FlxEase.quadOut});
						});
						FlxTween.tween(grayButton, {x: grayButton.x + 480 * (curSelected + 1)}, 0.2, {ease: FlxEase.quadOut});

						FlxTween.tween(topPause, {x: -1000}, 0.2, {ease: FlxEase.quadOut});
						FlxTween.tween(bottomPause, {x: 1280}, 0.2, {ease: FlxEase.quadOut, onComplete: function(ok:FlxTween)
						{
							close();
						}});
					case "Restart Song":
						MusicBeatState.resetState();
						FlxG.sound.music.volume = 0;
					case "Exit to menu":
						if (PlayState.isEncoreMode)
						{
							MusicBeatState.switchState(new EncoreState());
						}
						else if (PlayState.isStoryMode)
						{
							MusicBeatState.switchState(new StoryMenuState());
						}
						else if (PlayState.isFreeplayMode)
						{
							MusicBeatState.switchState(new FreeplayState());
						}
						else
						{
							MusicBeatState.switchState(new MainMenuState());
						}
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
				}
			}
		}
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (change == 1 || change == -1) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;


		for (item in grpMenuShit.members)
		{
			FlxTween.cancelTweensOf(item);

			item.x = FlxG.width - 400 - 80 * item.ID;
			item.y = FlxG.height / 2 + 70 + 100 * item.ID;

			if (item.ID == curSelected)
			{
				FlxTween.cancelTweensOf(grayButton);
				grayButton.x = FlxG.width - 400 - 80 * item.ID;
				grayButton.y = FlxG.height / 2 + 70 + 100 * item.ID;
				FlxTween.tween(item, {y: FlxG.height / 2 + 70 + 100 * item.ID - 20}, 0.2, {ease: FlxEase.quadOut, onComplete: function(lol:FlxTween)
				{
					FlxTween.tween(item, {y: item.y + 5}, 1, {ease: FlxEase.quadOut, type: FlxTween.PINGPONG});
					FlxTween.tween(grayButton, {y: grayButton.y - 5}, 1, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG});
				}});
			}
			else
			{
				FlxTween.tween(item, {y: FlxG.height / 2 + 70 + 100 * item.ID}, 0.2, {ease: FlxEase.quadOut});
			}
		}
		for (item in grpMenuShit2.members)
		{
			FlxTween.cancelTweensOf(item);
			item.x = grpMenuShit.members[item.ID].x + 25;
			item.y = FlxG.height / 2 + 70 + 100 * item.ID + 5;

			if (item.ID == curSelected) FlxTween.tween(item, {y: FlxG.height / 2 + 70 + 100 * item.ID - 20 + 5}, 0.2, {ease: FlxEase.quadOut, onComplete: function(lol:FlxTween)
			{
				FlxTween.tween(item, {y: item.y + 5}, 1, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG});
			}});
			else FlxTween.tween(item, {y: FlxG.height / 2 + 70 + 100 * item.ID + 5}, 0.2, {ease: FlxEase.quadOut});
		}
	}
}