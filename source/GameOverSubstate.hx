package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxCamera;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	
	var cameramoment:FlxCamera;
	
	var playingDeathSound:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var instance:GameOverSubstate;

	var sonicdeath:FlxSprite;

	var canAction:Bool = false;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		cameramoment = new FlxCamera();
		cameramoment.bgColor.alpha = 0;
		FlxG.cameras.add(cameramoment);

		PlayState.instance.setOnLuas('inGameOver', true);

		Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(boyfriend);

		sonicdeath = new FlxSprite(boyfriend.x, Std.int(boyfriend.y) - 350);
		sonicdeath.frames = Paths.getSparrowAtlas('SonicEXE_Overloom');
		sonicdeath.animation.addByPrefix('firstDEATH', 'APPEAR', 24, false);
		sonicdeath.animation.addByPrefix('loopDEATH', 'IDLE', 24, true);
		sonicdeath.animation.addByPrefix('retry', 'ACCEPT', 24, false);
		add(sonicdeath);

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		FlxG.camera.focusOn(new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y));

		boyfriend.playAnim('firstDeath');
		sonicdeath.animation.play('firstDEATH');
	}

	var isFollowingAlready:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);

		if (controls.ACCEPT && canAction)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			WeekData.loadTheFirstEnabledMod();
			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else if (PlayState.isEncoreMode)
				MusicBeatState.switchState(new EncoreState());
			else if (PlayState.isFreeplayMode)
				MusicBeatState.switchState(new FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}

		if (boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished && !playingDeathSound)
			{
				sonicdeath.animation.play('loopDEATH', true);
				canAction = true;
				coolStartDeath();
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			sonicdeath.animation.play('retry', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			FlxG.camera.flash(FlxColor.RED, 1);
			new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				var ok:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				ok.cameras = [cameramoment];
				add(ok);
				new FlxTimer().start(5, function(tmr:FlxTimer)
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
