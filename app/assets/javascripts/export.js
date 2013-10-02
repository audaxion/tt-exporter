$(document).ready(function() {
    $("#playlist").change(function() {
        var select_text = $(this).find("option:selected").text();
        if ($(this).val() !== "null") {
            $("#playlist_name").val(select_text);
        } else {
            $("#playlist_name").val('');
        }
    });
});