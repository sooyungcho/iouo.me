{renderable, div, h1, h4, ul, li, a, strong, text} = require 'teacup'

layout = require './layout'

module.exports = renderable ({balances}) -> layout content: ->
  div data: role: 'page', ->
    div data: role: 'header', ->
      h1 'I owe You'
    div data: role: 'content', ->
      ul '#balances', data: role: 'listview', ->
        balances.forEach (balance, i) ->
          [ower, owee] = balance.key
          amount = balance.value
          li ->
            a href: "/transactions/#{ower}/#{owee}", ->
              text "@#{ower} owes @#{owee}"
              strong '.ui-li-aside', "$#{amount}"
    div data: role: 'footer', ->
      h4 'You owe Me'
