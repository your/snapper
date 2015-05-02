$(document).on 'ready page:load', ->
	
  $('[data-status]').children(".snapshot-link").hide()
	

  poll = (div, callback) ->
    # Short timeout to avoid too many calls
    setTimeout ->
      console.log 'Calling...'
      $.get(div.data('status')).done (document) ->
        console.log 'Snapped ?', document.ready
        if document.ready
          # Yay, it's imported, we can update the content
          callback()
        else
          # Not finished yet, let's make another request...
          poll(div, callback)
    , 2000

  $('[data-status]').each ->
    div = $(this)

    # Initiate the polling
    poll div, ->
      div.children(".snapshot-link").show()
      div.children(".snapshot-processing").hide()