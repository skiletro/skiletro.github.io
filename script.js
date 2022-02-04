VANTA.DOTS({
  el: "*",
  mouseControls: false,
  touchControls: false,
  gyroControls: false,
  minHeight: 200.00,
  minWidth: 200.00,
  scale: 1.00,
  scaleMobile: 1.00,
  color: 0xAB4AFF,
  color2: 0x121212,
  backgroundColor: 0x121212,
  spacing: 32.00
})

let lastfmData = {
  baseURL:
    "https://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=",
  user: "skiletro",
  api_key: "fbbfaa13bbd7fb5fc9a57a6c0918725f",
  additional: "&format=json&limit=1"
};
  
let getSetLastFM = function() {
  $.ajax({
    type: "GET",
    url:
      lastfmData.baseURL +
      lastfmData.user + 
      "&api_key=" +
      lastfmData.api_key +
      lastfmData.additional,
    dataType: "json",
    success: function(resp) {
      var recentTrack = resp.recenttracks.track[0];

      try {
          var isPlaying = recentTrack['@attr'].nowplaying
      } catch (TypeError) {
          var isPlaying = false
      }

      var trackName = recentTrack.name;
      var trackUrl = recentTrack.url;
      var trackArtist = recentTrack.artist["#text"];
      var trackImg = recentTrack.image[2]["#text"];

      if (isPlaying) {

          $("#npName_js")
              .html("Listening to " + trackName)
              .attr("href", trackUrl);
  
          $("#npArtist_js")
              .html("by " + trackArtist);
  
          $("#npImg_js")
              .html("img here :)")
              .attr("src", trackImg);
      }

      //console.log(trackName);
      //console.log(trackUrl);
      //console.log(trackArtist);
      //console.log(trackImg);
    }
  });
};

let showaltpage = function() {
  if ($("#one").is(":visible")) {
    $("#one").hide();
    $("#two").show();
  } else {
    $("#one").show();
    $("#two").hide();
  }
}
