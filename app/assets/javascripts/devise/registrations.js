$(document).ready(function() {
  $("#edit_user").on("keypress", function (e) {
    if (e.keyCode == 13) {
      return false;
    }
  });
});
