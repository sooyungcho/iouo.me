{renderable, doctype, html, head, title, meta, link, body, script} = require 'teacup'

module.exports = renderable ({content}) ->
  doctype 5
  html ->
    head ->
      title 'I owe you owe me'
      meta name: 'viewport', content: 'width=device-width, initial-scale=1'
      link rel: 'stylesheet', href: '/stylesheets/jquery.mobile-1.3.0.min.css'
    body ->
      content()
      script src: '/javascripts/jquery-1.9.1.min.js', ''
      script src: '/javascripts/jquery.mobile-1.3.0.min.js', ''
      script src: '//platform.twitter.com/widgets.js', charset: 'utf-8', ''
      script src: '/javascripts/iouo.js', ''
