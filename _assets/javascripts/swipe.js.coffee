#= require hammer
windowWidth = window.innerWidth

$ ->
    # Redefine windowWidth.
    windowWidth = window.innerWidth
    return unless windowWidth <= 480

    $container = $ '#side-scroll-container'
    $cards = $container.find '.scroll-item-wrapper'

    # Hide all cards elements except for the first one.
    $cards.hide()
        .first()
        .show()

    $cards.each (i, el) ->
        Hammer(el).on 'drag', dragEl
        Hammer(el).on 'dragend', checkAndTransition
        Hammer(el).on 'swipeleft', transitionLeft
        Hammer(el).on 'swiperight', transitionRight

dragEl = (e) ->
    @x = e.gesture.deltaX * 1.2
    @style.webkitTransform = "translate3d(#{@x}px, 0, 0)"

# Transition if less than 2/3 of card is still shown.
checkAndTransition = (e) ->
    if Math.abs(@x) < windowWidth/3  # Still mostly in view.
        resetCard.call @
    else if @x < 0  # Navigate right.
        transitionRight.call @
    else if @x > 0  # Navigate left.
        transitionLeft.call @

resetCard = ->
    @style.webkitTransition = '-webkit-transform 0.2s ease-in-out'
    @style.webkitTransform = "translate3d(0, 0, 0)"
    setTimeout =>
        @style.webkitTransition = 'none'
        return
    , 200

transitionRight = (e) ->
    $currentCard = $ @
    nextCard = $currentCard.next('.scroll-item-wrapper').get 0
    unless nextCard?
        resetCard.call @
        return

    transitionOut.call @, 'left'
    $currentCard.one 'animationend webkitTransitionEnd', ->
        $currentCard.hide()
        transitionIn.call nextCard

transitionLeft = (e) ->
    $currentCard = $ @
    prevCard = $currentCard.prev('.scroll-item-wrapper').get 0
    unless prevCard?
        resetCard.call @
        return
    transitionOut.call @, 'right'
    $currentCard.one 'animationend webkitTransitionEnd', ->
        $currentCard.hide()
        transitionIn.call prevCard

transitionOut = (endPos='left') ->
    if endPos is 'left'
        endPosX = windowWidth * -1.5
    else if endPos is 'right'
        endPosX = windowWidth * 1.5
    else
        resetCard.call @
        return

    duration = 0.2
    @style.webkitTransition = "-webkit-transform #{duration}s ease-in-out"
    @style.webkitTransform = "translate3d(#{endPosX}px, 0, 0)"

transitionIn = ->
    # Center.
    @style.webkitTransform = "translate3d(0, 0, 0)"

    $el = $ @
    $el.one('animationend webkitAnimationEnd', ->
        $el.removeClass 'animated pop-in'
    )
    .addClass('animated pop-in')
    .show()
