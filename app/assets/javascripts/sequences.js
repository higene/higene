$(function() {
  var $format = $('#format');
  var $inputConditionName = $('#input_condition_name');
  var showHideConditionName = function(value) {
    if (value === 'xprs') {
      $inputConditionName.removeClass('hidden');
    } else {
      $inputConditionName.addClass('hidden');
    }
  };

  showHideConditionName($format.val());
  $format.change(function() {
    showHideConditionName($(this).val());
  });

  var $searchByNameForm = $('#search_by_name_form');
  $searchByNameForm.submit(function(event) {
    event.preventDefault();
    window.location.href = window.location.href.split('?')[0] + '/' + $("#name").val().trim();
  });
});
