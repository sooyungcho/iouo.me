async = require 'async'
querystring = require 'querystring'

db = require '../config/db'
twitter = require '../config/twitter'

twitterSearchSinceId = null

IOU = exports

IOU.latest = (cb) ->
  db.view 'iouome', 'by_raw_id', descending: true, limit: 1, (err, res) ->
    return cb err if err
    cb null, res.rows.length && res.rows[0].key

IOU.searchTwitter = (cb) ->
  return performSearch twitterSearchSinceId, cb if twitterSearchSinceId
  IOU.latest (err, sinceId) ->
    return cb err if err
    performSearch sinceId, cb

IOU.fetchTweet = (id, cb) ->
  twitter.get "statuses/show/#{id}", (err, tweet) ->
    return cb err if err
    processTweet tweet, cb

IOU.balances = (cb) ->
  db.view 'iouome', 'balances', group_level: 1, (err, res) ->
    cb err, res && res.rows.sort (a, b) ->
      b.value - a.value

IOU.balancesFor = (ower, cb) ->
  db.view 'iouome', 'balances',
    group_level: 2
    startkey: [ower]
    endkey: [ower, {}]
  , (err, res) ->
    cb err, res && res.rows.sort (a, b) ->
      b.value - a.value

IOU.ledger = (ower, owee, cb) ->
  db.view 'iouome', 'balances',
    descending: true
    reduce: false
    startkey: [ower, owee, {}]
    endkey: [ower, owee]
    include_docs: true
   , (err, res) ->
    cb err, res && res.rows

performSearch = (sinceId, maxId, cb) ->
  if typeof maxId == 'function'
    cb = maxId
    maxId = null
  params =
    q: '#iou'
    result_type: 'recent'
    count: 100
    include_entities: true
  params.since_id = sinceId if sinceId
  params.max_id = maxId if maxId
  twitter.get 'search/tweets', params, (err, data) ->
    return cb err if err
    async.parallel [
      (cb) ->
        async.each data.statuses, processTweet, cb
      (cb) ->
        if data.search_metadata.next_results
          nextParams = querystring.parse data.search_metadata.next_results.slice(1)
          performSearch sinceId, nextParams.max_id, cb
        else
          cb()
    ], (err) ->
      refreshParams = querystring.parse data.search_metadata.refresh_url.slice(1)
      twitterSearchSinceId = refreshParams.since_id unless twitterSearchSinceId > refreshParams.since_id
      return cb err if err

processTweet = (tweet, cb) ->
  doc =
    _id: "twitter/#{tweet.id_str}"
    raw: tweet
    ower: tweet.user && tweet.user.id_str
    owee: tweet.in_reply_to_user_id_str
    amount: parseFloat m[1] if m = tweet.text.match /#iou\s+\$([.\d]+)/i
  if doc.ower && doc.owee && doc.amount
    db.insert doc, cb
  else
    cb()
