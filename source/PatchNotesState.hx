package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flash.text.TextField;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;

#if windows
import Discord.DiscordClient;
#end

class PatchNotesState extends MusicBeatState
{
    var scrollingBG:FlxBackdrop;
    var infoblock:FlxSprite;
    var spikesDarkUp:FlxBackdrop;
    var spikesLightUp:FlxBackdrop;
    var spikesDarkDown:FlxBackdrop;
    var spikesLightDown:FlxBackdrop;
    var boundries:FlxSprite;
    var arrows:FlxSprite;
    var title:FlxText;
    var version:FlxText;
    var added:FlxText;
    var removed:FlxText;
    var improvements:FlxText;
    var addeddescription:FlxText;
    var removeddescription:FlxText;
    var improvementsdescription:FlxText;
    var details:FlxText;

    override function create()
    {
        
        scrollingBG = new FlxBackdrop(Paths.image('patchnotesstuff/background'), 0, 0, true, false);
        scrollingBG.scale.x = 0.35;
        scrollingBG.scale.y = 0.35;
        scrollingBG.screenCenter(Y);
        add(scrollingBG);

        infoblock = new FlxSprite(0, 0).loadGraphic(Paths.image('patchnotesstuff/infoblock'));
        infoblock.screenCenter();
        infoblock.updateHitbox();
        add(infoblock);

        spikesDarkUp = new FlxBackdrop(Paths.image('patchnotesstuff/spikesDarkU'), 0, 0, true, false);
        spikesDarkUp.scale.x = 0.5;  
        spikesDarkUp.scale.y = 0.5;
        spikesDarkUp.y = 0;
        add(spikesDarkUp);

        spikesLightUp = new FlxBackdrop(Paths.image('patchnotesstuff/spikesLightU'), 0, 0, true, false);
        spikesLightUp.scale.x = 0.5;  
        spikesLightUp.scale.y = 0.5;
        spikesLightUp.y = -30;
        add(spikesLightUp);

        spikesDarkDown = new FlxBackdrop(Paths.image('patchnotesstuff/spikesDarkD'), 0, 0, true, false);
        spikesDarkDown.scale.x = 0.5;  
        spikesDarkDown.scale.y = 0.5;
        spikesDarkDown.y = 610;
        add(spikesDarkDown);

        spikesLightDown = new FlxBackdrop(Paths.image('patchnotesstuff/spikesLightD'), 0, 0, true, false);
        spikesLightDown.scale.x = 0.5;  
        spikesLightDown.scale.y = 0.5;
        spikesLightDown.y = 640;
        add(spikesLightDown);
        
        boundries = new FlxSprite(0, 0).loadGraphic(Paths.image('patchnotesstuff/boundries'));
        boundries.screenCenter();
        boundries.updateHitbox();
        add(boundries);

        arrows = new FlxSprite(0, 0).loadGraphic(Paths.image('patchnotesstuff/funniArrows'));
		arrows.scrollFactor.set();
		arrows.antialiasing = true;
        arrows.scale.x = 1;
        arrows.scale.y = 1;
        arrows.screenCenter(X);
        arrows.y = 30;
		arrows.updateHitbox();
		add(arrows);
		FlxTween.tween(arrows, {y: arrows.y - 50}, 1, {ease: FlxEase.quadInOut, type: PINGPONG});

        
        title = new FlxText();
        title.text = "The EXE Collection\nPATCH NOTES";
        title.alignment = CENTER;
        title.scale.set(5, 5);
        title.y = 35;
        title.screenCenter(X);
        add(title);

        version = new FlxText();
        version.text = "DEV BUILD 6";
        version.alignment = CENTER;
        version.scale.set(4, 4);
        version.y = 130;
        version.screenCenter(X);
        add(version);

        added = new FlxText();
        added.text = "ADDED";
        added.scale.set(3.5, 3.5);
        added.x = 250;
        added.y = 170;
        add(added);

        removed = new FlxText();
        removed.text = "REMOVED";
        removed.scale.set(3.5, 3.5);
        removed.screenCenter(X);
        removed.y = 170;
        add(removed);

        improvements = new FlxText();
        improvements.text = "IMPROVEMENTS";
        improvements.scale.set(3.5, 3.5);
        improvements.x = 980;
        improvements.y = 170;
        add(improvements);

        
        addeddescription = new FlxText();
        addeddescription.text = "Patch Notes\nYCR Encore\nYRC Stage";
        addeddescription.alignment = CENTER;
        addeddescription.scale.set(2.5, 2.5);
        addeddescription.x = added.x - 20;
        addeddescription.y = added.y + 100;
        add(addeddescription);

        removeddescription = new FlxText();
        removeddescription.text = "Some Unneccessary Code\nExtras Button in Main Menu";
        removeddescription.alignment = CENTER;
        removeddescription.scale.set(2.5, 2.5);
        removeddescription.x = removed.x - 48;
        removeddescription.y = removed.y + 100;
        add(removeddescription);

        
        improvementsdescription = new FlxText();
        improvementsdescription.text = "cloned boyfriend\ncharting bugs";
        improvementsdescription.alignment = CENTER;
        improvementsdescription.scale.set(2.5, 2.5);
        improvementsdescription.x = improvements.x - 10;
        improvementsdescription.y = improvements.y + 100;
        add(improvementsdescription);

        details = new FlxText();
        details.text = "press ESCAPE to go back.";
        details.alignment = CENTER;
        details.scale.set(5, 5);
        details.y = 660;
        details.screenCenter(X);
        add(details);
        
        DiscordClient.changePresence("In the Main Menu", "Patch Notes");

        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        
        scrollingBG.x -= 1;
        spikesLightDown.x -= 0.5;
        spikesDarkDown.x -= 0.7;
        spikesLightUp.x += 0.5;
        spikesDarkUp.x += 0.7;
        

        if(controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }
    }
}