#= require hammer
#= require within-viewport

# We can do some cool stuff here on mobile to make this super addictive to read.
# Make a Jelly-like UI where people swipe to navigate among cards. This would
# require managing each card on a stack with push/pop to navigate between views.

$ ->
    $container = $ '#side-scroll-container'
    containerEl = $container.get 0
    $cards = $container.find '.scroll-item-wrapper'

    # Hide all cards elements.
    $cards.hide()

    # Find which card to focus on.
    currentCardIndex = 0
    cardsCount = $cards.length
    cardsCount0 = $cards.length - 1
    for card, i in $cards
        $card = $ card
        halfCardWidth = $card.width() / 2
        majorityInView = withinViewport(card, {left: halfCardWidth}) or withinViewport(card, {right: halfCardWidth})
        if majorityInView
            currentCardIndex = i
            $card.show()
            break

    # Show the current card.
    # $cards[currentCardIndex].show

    $cards.each (i, el) ->
        Hammer(el).on 'drag', dragEl
        Hammer(el).on 'dragend', checkAndTransition

    # # Navigate forward.
    # swipeLeft = Hammer(containerEl).on 'swipeleft', (event) ->
    #     if currentCardIndex < cardsCount0
    #         prevCardIndex = currentCardIndex
    #         currentCardIndex++
    #         navigateCards $cards[prevCardIndex], $cards[currentCardIndex]
    #     else
    #         currentCardIndex = cardsCount0

    # # Navigate backward.
    # swipeRight = Hammer(containerEl).on 'swiperight', (event) ->
    #     if currentCardIndex > 0
    #         prevCardIndex = currentCardIndex
    #         currentCardIndex--
    #         navigateCards $cards[prevCardIndex], $cards[currentCardIndex]
    #     else
    #         currentCardIndex = 0

windowWidth = window.innerWidth

dragEl = (e) ->
    @x = e.gesture.deltaX * 0.4
    @style.webkitTransform = "translate3d(#{@x}px, 0, 0)"

checkAndTransition = (e) ->
    if Math.abs(@x) < windowWidth/2  # Still mostly in view.
        resetCard.call @
    else if @x < 0  # Navigate right.
        nextCard = $(@).next('.scroll-item-wrapper').get(0)
        if nextCard?
            transitionRight @, nextCard
        else
            resetCard.call @
    else if @x > 0  # Navigate left.
        prevCard = $(@).prev('.scroll-item-wrapper').get(0)
        if prevCard?
            transitionLeft @, prevCard
        else
            resetCard.call @

resetCard = ->
    @style.webkitTransition = '-webkit-transform 0.2s ease-in-out'
    @style.webkitTransform = "translate3d(0, 0, 0)"
    setTimeout =>
        @style.webkitTransition = 'none'
        return
    , 200

transitionRight = (from, to) ->
    transitionOut.call from, 'left'
    $(from).one 'animationend webkitTransitionEnd', ->
        $(from).hide()
        transitionIn.call to

transitionLeft = (from, to) ->
    transitionOut.call from, 'right'
    $(from).one 'animationend webkitTransitionEnd', ->
        $(from).hide()
        transitionIn.call to

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
