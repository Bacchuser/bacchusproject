# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(() ->

  $("input.js-datepicker").datepicker {
      dateFormat: "dd/mm/yy",
      onClose: (selectedDate) ->
          $(this).closest("form").find("input.js-after-calendar").datepicker( "option", "minDate", selectedDate );
    }

)