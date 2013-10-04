$(document).ready(function() {
    $("#playlist").change(function() {
        var select_text = $(this).find("option:selected").text();
        if ($(this).val() !== "null") {
            $("#playlist_name").val(select_text);
        } else {
            $("#playlist_name").val('');
        }
    });

    pollForProgressBars();
});

var pollForProgressBars = function() {
    console.log("Polling for progress bars...")
    updateProgressBars();
    setTimeout(function() { pollForProgressBars(); }, 3000);
}


var updateProgressBars = function() {
    var playlists = $(".progress-bar");
    playlists.each(function(index) {
        var playlist = $(this);
        var playlist_id = playlist.attr('id');
        console.log("Playlist id: " + playlist_id);
        $.get('/playlist/progress/' + playlist_id, function(data) {
            console.log(data + "% complete");
            playlist.width(data + '%');
            if (parseFloat(data) < 100.0) {
                $("#parent" + playlist_id).addClass("progress-striped active");
                playlist.removeClass("progress-bar-success");
            } else {
                $("#parent" + playlist_id).removeClass("progress-striped active");
                playlist.addClass("progress-bar-success");
            }
            $("#processPercent" + playlist_id).text(data);
        })
    });
}