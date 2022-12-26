
package;

class CharSongList
{
  public static var data:Map<String,Array<String>> = [
      "majin" => ["endless", "endless-og", "endless-us", "endeavours"],
      "lord x" => ["fate", "hellbent", "cycles", "your-lord"],
      "tails doll" => ["sunshine", "soulless"],
      "fleetway" => ["chaos"],
      "fatalerror" => ["fatality", "trashed"],
      "chaotix" => ["my-horizon", "our-horizon"],
      "chotix" => ["good-for-them", "long-sky"],
      "curse" => ["malediction"],
      "starved" => ["prey", "fight-or-flight"],
      "xterion" => ["substantial", "digitalized"],
      "needlemouse" => ["round-a-bout", "relax", "watch-your-tone"],
      "luther" => ["her-world"],
      "hog" => ["hedge", "manual-blast"],
      "sunky" => ["milk"],
      "ice cube" => ["ice-cube"],
      "sanic" => ["too-fest", "sn1pe"],
      "coldsteel" => ["personel"],
      "sl4sh" => ["b4cksl4sh"],
      "sonic has passed" => ["burning"],
      "requital" => ["forestall-desire"],
      "normalcd" => ["found-you"],
      "bf exe" => ["eye-to-eye"],
      "satanos" => ["perdition"],
      "christmas charols" => ["slaybells"],
      "sonichu" => ["shocker", "electrical-shock"],
      "devoid" => ["hollow"],
      "secret history tails" => ["mania"],
      // "sally-alt" => [""]
      "melthog" => ["melting", "confronting"],
      // "apollyon" => [""],
      // "exetior" => [""],
      // "demogri" => [""],
      // "griatos" => [""]
      //
  ];

    public static var characters:Array<String> = [ // just for ordering
      "majin",
      "lord x",
      "tails doll",
      "fleetway",
      "fatalerror",
      "chaotix",
      "curse",
      "starved",
      "xterion",
      "needlemouse",
      "luther",
      "hog",
      "sunky",
      "ice cube",
      "sanic",
      "coldsteel",
      "sl4sh",
      "sonic has passed",
      "requital",
      "normalcd",
      "bf exe",
      "satanos",
      "christmas charols",
      "sonichu",
      "devoid",
      "melthog"
    ];

    // TODO: maybe a character display names map? for the top left in FreeplayState

    public static var songToChar:Map<String,String>=[];

    public static function init(){ // can PROBABLY use a macro for this? but i have no clue how they work so lmao
      // trust me I tried
      // if shubs or smth wants to give it a shot then go ahead
      // - neb
      songToChar.clear();
      for(character in data.keys()){
        var songs = data.get(character);
        for(song in songs)songToChar.set(song,character);
      }
    }

    public static function getSongsByChar(char:String)
    {
      if(data.exists(char))return data.get(char);
      return [];
    }

    public static function isLastSong(song:String)
    {
        /*for (i in songs)
        {
            if (i[i.length - 1] == song) return true;
        }
        return false;*/
      if(!songToChar.exists(song))return true;
      var songList = getSongsByChar(songToChar.get(song));
      return songList[songList.length-1]==song;
    }
}
