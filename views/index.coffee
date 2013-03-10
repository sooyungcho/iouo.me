{renderable, div, h1, h4, ul, li, a, img, strong, text} = require 'teacup'

layout = require './layout'

module.exports = renderable ({balances}) -> layout content: ->
  div data: role: 'page', ->
    div data: role: 'header', ->
      img '.logo', src: '/images/iou-logo.png'
      h1 'i owe you owe me'
    div data: role: 'content', ->
      ul '#balances', data: role: 'listview', ->
        balances.forEach (balance, i) ->
          [ower, owee] = balance.key
          amount = balance.value
          li data: role: 'list-divider', "@#{ower} owes" unless i && ower == balances[i-1].key[0]
          li ->
            a href: "/transactions/#{ower}/#{owee}", ->
              text "@#{owee}"
              strong '.ui-li-aside', "$#{amount}"
    div data: role: 'footer', position: 'fixed', ->
      div data: role: 'navbar', ->
        ul ->
          li ->
            a '.ui-btn', href: '/owe', data: role: 'button', ->
              h1 "Owe Someone"
