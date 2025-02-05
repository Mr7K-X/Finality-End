package tempo.api;

typedef DiscordPresenceParams = {
    var details:Null<String>;
    var ?state:String;
    var ?largeImageKey:String;
    var ?largeImageText:String;
    var ?smallImageKey:String;
    var ?smallImageText:String;
}