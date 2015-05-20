$(document).on 'ready page:load', ->

  $('[data-status]').children("#snapshot-done").hide()
  $('[data-status]').children(".snapshot-link").hide()
  $('[data-status]').children("#snapshot-error").hide()
  $(".box").hide()
  $(".box").show("slide", { direction: "left" }, 400)
	
  error = false
  first_poll = true
  msg = ''
  wait = ''
	  
  poll = (div, callback) ->
    # Short timeout to avoid too many calls
    setTimeout ->
      console.log 'Calling...'
      $.get(div.data('status')).done (document) ->
        wait = moment.unix(moment().unix()+Number(document.wait)).format("YYYY/MM/DD HH:mm:ss") if first_poll == true
        first_poll = false if wait != ''
        console.log 'wait up to: ', wait
        $("#clock").countdown wait, (event) ->
          $this = $(this).html(event.strftime("<span>%M</span> min " + "<span>%S</span> sec"))
        console.log 'Snapped ?', document.ready
        msg = document.msg
        if document.ready == -1
          error = true
        if document.ready == 1 || document.ready == -1
          # Yay, it's imported, we can update the content
          callback()
        else
          # Not finished yet, let's make another request...
          poll(div, callback)
    , 5000

  $('[data-status]').each ->
    div = $(this)
	
    # $('.inputarea').hide()

    # Initiate the polling
    poll div, ->
      if error
        $('[data-status]').children("#snapshot-processing").children("#loading").hide()
        $('[data-status]').children("#snapshot-processing").children("#wait").hide()
        $('[data-status]').children("#snapshot-processing").children("#clock").hide()
        div.children("#snapshot-error").text('ERROR: Snapshot failed - ' + msg)
        div.children("#snapshot-error").show("slide", { direction: "left" }, 400)
      else
        div.children(".snapshot-link").show("slide", { direction: "left" }, "slow")
        $('[data-status]').children("#snapshot-processing").hide()
        $('[data-status]').children("#snapshot-done").show("slide", { direction: "left" }, 400)
      true
