# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  for pover in $('a[data-toggle=popover]')
    do (pover) ->
      if pover.classList.contains("help-tip")
        $(pover).popover({
          trigger: 'hover',
          delay: {
            show: 100,
            hide: 500
          }
        });
  

$(document).on 'click', 'form .toggle-nested', (event) ->
  element = $('#' + $(this).data('field'))
  prefix = $(this).data('prefix')
  if $(this).prop("checked")
    if element.html().trim() == ""
      element.html($(this).data('create'))
    else
      $('#' + prefix + '_destroy').val(false)
      element.show()
  else
    if $('#' + prefix + 'id').val() == undefined
      element.html("")
    else
      $('#' + prefix + '_destroy').val(true)
      element.hide()


  
#console.log($('a[data-toggle=popover]'))
