package;

import flixel.effects.FlxFlicker;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{

	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var curDifficulty:Int = 1;
	var curdiff:Int = 2;
	var real:Int = 0;
	var oneclickpls:Bool = true;

	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var leftArrow2:FlxSprite;
	var rightArrow2:FlxSprite;

	var selection:Bool = false;

	var songArray = ['too-slow', 'you-cant-run', 'triple-trouble'];
	var portrait:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		switch (FlxG.save.data.storyProgress)
		{
			case 1:
				songArray = ['too-slow', 'you-cant-run'];
			case 2:
				songArray = ['too-slow', 'you-cant-run', 'triple-trouble'];
		}

		portrait = new FlxSprite(450, 79).loadGraphic(Paths.image('fpstuff/too-slow'));
		portrait.setGraphicSize(Std.int(portrait.width * 0.275));
		portrait.antialiasing = true;
		portrait.updateHitbox();
		add(portrait);

		sprDifficulty = new FlxSprite(550, 600);
		sprDifficulty.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('normal');
		add(sprDifficulty);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		leftArrow = new FlxSprite(sprDifficulty.x - 150, sprDifficulty.y);
		leftArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		leftArrow.setGraphicSize(Std.int(leftArrow.width * 0.8));
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(leftArrow);

		rightArrow = new FlxSprite(sprDifficulty.x + 230, sprDifficulty.y);
		rightArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		rightArrow.setGraphicSize(Std.int(rightArrow.width * 0.8));
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(rightArrow);

		leftArrow2 = new FlxSprite(325, 136 + 5);
		leftArrow2.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets_alt');
		leftArrow2.setGraphicSize(Std.int(leftArrow2.width * 0.8));
		leftArrow2.animation.addByPrefix('idle', "arrow left");
		leftArrow2.animation.addByPrefix('press', "arrow push left");
		leftArrow2.animation.play('idle');
		add(leftArrow2);

		rightArrow2 = new FlxSprite(820, 136 + 5);
		rightArrow2.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets_alt');
		rightArrow2.setGraphicSize(Std.int(rightArrow2.width * 0.8));
		rightArrow2.animation.addByPrefix('idle', "arrow right");
		rightArrow2.animation.addByPrefix('press', "arrow push right");
		rightArrow2.animation.play('idle');
		add(rightArrow2);

		super.create();
	}

	function changediff(diff:Int = 1)
	{
		curdiff += diff;

		if (curdiff == 0)
			curdiff = 3;
		if (curdiff > 3)
			curdiff = 1;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		switch (curdiff)
		{
			case 1:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 2:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 3:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}
		sprDifficulty.alpha = 0;
		sprDifficulty.y = leftArrow.y - 15;
		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 10, alpha: 1}, 0.07);
	}

	function changeAct(diff:Int = 1)
	{
		if (FlxG.save.data.storyProgress != 0)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));

			real += diff;
			if (real < 0)
				real = songArray.length - 1;
			else if (real > songArray.length - 1)
				real = 0;

			portrait.loadGraphic(Paths.image('fpstuff/' + songArray[real]));
		}
	}

	function changeSelection()
	{
		selection = !selection;

		if (selection)
		{
			leftArrow.setPosition(345, 145);
			rightArrow.setPosition(839, 145);
			leftArrow2.setPosition(550 - 160 - 5, 600 - 2);
			rightArrow2.setPosition(550 + 230 - 15, 600 - 2);
		}
		else
		{
			leftArrow2.setPosition(325, 136 + 5);
			rightArrow2.setPosition(820, 136 + 5);
			leftArrow.setPosition(550 - 150, 600);
			rightArrow.setPosition(550 + 230, 600);
		}
	}

	override public function update(elapsed:Float)
	{
		if (controls.UI_LEFT && oneclickpls)
			leftArrow.animation.play('press');
		else
			leftArrow.animation.play('idle');

		if (controls.UI_LEFT_P && oneclickpls)
		{
			if (selection)
				changeAct(-1);
			else
				changediff(-1);
		}

		if (controls.UI_RIGHT && oneclickpls)
			rightArrow.animation.play('press');
		else
			rightArrow.animation.play('idle');

		if (controls.UI_RIGHT_P && oneclickpls)
		{
			if (selection)
				changeAct(1);
			else
				changediff(1);
		}

		if ((controls.UI_UP_P && oneclickpls) || (controls.UI_DOWN_P && oneclickpls))
			changeSelection(); // huh

		if (controls.BACK && oneclickpls)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

				if (controls.ACCEPT)
		{
			if (oneclickpls)
			{
				oneclickpls = false;
				var curDifficulty = '';

				FlxG.sound.play(Paths.sound('confirmMenu'));

				if (curdiff == 4)
					{

						PlayState.SONG = Song.loadFromJson('too-slow-encore', 'too-slow-encore');

						new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								// LoadingState.loadAndSwitchState(new PlayState(), true); //save this code for the cutsceneless build of the game
								//var video:MP4Handler = new MP4Handler();
							//	video.playVideo(Paths.video('tooslowcutscene1'));
							//	video.finishCallback = function()
								//{
									LoadingState.loadAndSwitchState(new PlayState());
								//}
							});
					}

				else if (FlxG.save.data.storyProgress == 0)
				{
					PlayState.storyPlaylist = ['too-slow', 'you-cant-run', 'triple-trouble'];
					PlayState.isStoryMode = true;

					curdiff = 3;
					PlayState.storyDifficulty = curdiff;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + curDifficulty, PlayState.storyPlaylist[0].toLowerCase());
					PlayState.storyWeek = 1;
					PlayState.campaignScore = 0;

					FlxG.log.add("Hey there! This is here incase it doesn't work correctly. Don't mind this.");
				}
				else
				{
					curDifficulty = '-hard';

					PlayState.SONG = Song.loadFromJson(songArray[real].toLowerCase() + curDifficulty, songArray[real].toLowerCase());
					PlayState.isStoryMode = false;
					LoadingState.loadAndSwitchState(new PlayState());
				}
				if (songArray[real] == 'you cant run')
				{
					PlayState.storyPlaylist = ['you cant run', 'triple trouble'];
					PlayState.isStoryMode = true;
					curDifficulty = '-hard';

					PlayState.storyDifficulty = FlxG.save.data.storyDiff = curdiff;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + curDifficulty, PlayState.storyPlaylist[0].toLowerCase());
					PlayState.storyWeek = 1;
				}
				if (songArray[real] == 'too slow')
				{
					new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							// LoadingState.loadAndSwitchState(new PlayState(), true); //save this code for the cutsceneless build of the game
							//var video:MP4Handler = new MP4Handler();
						//	video.playVideo(Paths.video('tooslowcutscene1'));
						//	video.finishCallback = function()
							//{
								LoadingState.loadAndSwitchState(new PlayState());
							//}
						});
				}
			}
		}
		super.update(elapsed);
	}
}
