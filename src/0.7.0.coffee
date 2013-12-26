###

Donate?
PP:  donation@zaku.eu
BTC: 16bs6kN6wTVT7NUCMWxjCZ4UCTy3b9KVWX
LTC: LYkd9Vo52NotPCpB6AUQ8Cg7sjF1meLsif

---

The MIT License (MIT)

Copyright (c) 2014 Tamino Martinius

Copyright (c) 2014 http://cdn.getshar.es
Copyright (c) 2014 http://gethar.es
Copyright (c) 2014 http://zaku.eu

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

###

idNr = 1

class @GetShare
  constructor: (options) ->
    gs = @
    network = @getNetworkDefaults(options?.network or "")
    @extend(@,
    # root:               # create button inside root if given     | jQuery element
    # network: null
    # share:
    #   url: "-"             # share this url
    #   message:          # Statusmessage
      autoInit: true
      popover:
        width: "300px"
        height: "100px"
        position: "bottom right"
        attr:
          "class": "getshare-popover"
      attr:
        "id": "getshare-#{idNr++}"
        "class": "getshare"
      button:
        icon:
    #     url:            # url of icon placed in front of button  | icon or text is required
          style:
            "margin": "1px 2px"
            "height": "14px"
            "max-width": "12px"
    #   text:             # text placed in button                  | icon or text is required
        attr:
    #     href:           # target url on button click
          "class": "getshare-button"
      counter:
        mode: "countUp"   # count, countUp, amount, amountUp, hide
        position: "inside"# inside, spitBorder, split, bubble
        loader: "spinner" # fade, spinner                          | only enabled if counter != hide
        count: 0
        countLoaded: false
    #   decimals:         # 0-10                                   | only enabled for amounts
    #   query:
    #     url:            # Url for jsonp callback to get count
    #     path:           # Path inside callback item to get count
        attr:
          "class": "getshare-counter"
    ,network, options)
    if @network is "vk"
      window.VK = {}
      window.VK.Share = {}
      window.VK.Share.count = $.proxy (a, count) ->
        gs.counter.count = count
      , @

    @button.attr.href ||= ""
    @counter.query ||= {}
    @counter.query.url ||= ""
    if not @root?
      rootId = "root-#{@attr.id}"
      document.write "<span id=\"#{rootId}\"/>"
      @root = $ "##{rootId}"
    @elem = jQuery "<span></span>"
    @switchElem = jQuery "<input type=\"checkbox\" id=\"cb-#{@attr.id}\"/>"
    @elem.append @switchElem
    @switchElem.change () ->
      target = gs.popover.target or gs.attr.id
      $this = jQuery @
      checked = $this.is ":checked"
      jQuery(".getshare input[type=checkbox]").attr "checked", false
      if checked and gs.popover.content?
        $this.attr "checked", true
        $popover = $("##{gs.attr.id} .#{gs.popover.attr.class} > div")
        $popover = gs.popover.elem.find("div") if $popover.length <= 1
        $popover.html gs.replaceString(gs.popover.content)
      else if gs.popover.url?
        left = (screen.width / 2) - (gs.popover.width / 2)
        top = (screen.height / 2) - (gs.popover.height / 2)
        options = "menubar=1,resizable=1,width=#{gs.popover.width},height=#{gs.popover.height},top=#{top},left=#{left}"
        options = null if gs.popover.options is false
        win = window.open gs.replaceString(gs.popover.url), target, options
        win.focus()

    @button.elem = jQuery "<label for=\"cb-#{@attr.id}\"/>"
    @counter.elem = jQuery "<span/>"

    @elem.attr key, value for key, value of (@attr or {})
    @button.elem.attr key, value for key, value of (@button?.attr or {})
    @counter.elem.attr key, value for key, value of (@counter?.attr or {})

    @button.elem.addClass "getshare-icon" if @button?.icon?
    @button.elem.addClass "getshare-button-#{@network}" if @network?
    @button.elem.append "<span class=\"getshare-text\">#{@button.text}</span>" if @button?.text?

    @elem.append @button.elem
    if @counter?.mode is "count" or @counter?.mode is "countUp" or @counter?.mode is "amount" or @counter?.mode is "amountUp"
      @counter.position = "split border" if @counter.position is "splitBorder"
      @counter.elem.addClass @counter.position
      if @counter.position is "bubble"
        @elem.append @counter.elem
      else
        @button.elem.append @counter.elem
    if gs.popover.content?
      @popover.elem = jQuery """
        <div>
          <label for=\"cb-#{@attr.id}\">✖</label>
          <div/>
        </div>
      """
      @popover.elem.attr key, value for key, value of (@popover?.attr or {})
      @popover.elem.addClass @popover.position
      @popover.elem.css "width", @popover.width
      @popover.elem.css "height", @popover.height
      @popover.elem.css "top", "-#{@popover.height}"
      @elem.append @popover.elem
    @root.append @elem
    @setUrl @share.url if @autoInit
  encode: (str) ->
    return "" if not str?
    encodeURIComponent(str.toString()).replace(/'/g,"%27").replace(/"/g,"%22")
  setUrl: (url, callback) ->
    gs = @
    @share ||= {}
    @share.url = url || window.location.href
    @share.url += "/" if @share.url.length > 8 and @share.url.substr(8).indexOf("/") < 0
    @share.encUrl = @encode @share.url
    @share.encMessage = @encode @share.message
    @share.encImageUrl = @encode @share.imageUrl
    @counter.query.encUrl = @replaceString @counter.query.url
    @button.elem.attr "href", @replaceString(@button.attr.href)
    if url? and @network is "weibo" and url.indexOf("http://t.cn") is -1
      @counter.query.encUrlShortener = @replaceString @counter.query.urlShortener
      $.getJSON @counter.query.encUrlShortener, (res) ->
        gs.setUrl res.data.urls[0].url_short, callback
      return
    @getCount (elem) ->
      gs.updateCounterHtml()
      $.proxy(callback, gs)(elem) if callback
  extend: (target, elements...) ->
    target ||= {}
    for src in elements
      for srcKey, srcVal of src
        if typeof srcVal is "object" and srcVal? and not srcVal.length?
          target[srcKey] ||= {}
          @extend target[srcKey], srcVal
        else
          target[srcKey] = srcVal
    target
  updateCounterHtml: () ->
    gs = @
    $counter = $("##{@attr.id} .#{@counter.attr.class}")
    $counter = @counter.elem if $counter.length <= 1
    $counter.removeClass "getshare-loader"
    $counter.html @convertCount(@counter.count)
  getCount: (callback) ->
    gs = @
    @counter.elem.html ""
    @counter.elem.addClass "getshare-loader"
    $.getJSON @counter.query.encUrl, (res) ->
      count = gs.extractCount res, (gs.counter?.query?.path or "").split "." if res?
      count ?= 0
      count = 0 if isNaN(count)
      gs.counter.count = count
      $.proxy(callback, gs)(res) if callback?
    .fail () ->
      $.proxy(callback, gs)() if callback?
  extractCount: (item, query) ->
    count = 0
    if item? and query?
      if $.isArray item
        count += @extractCount subItem, query.slice() for subItem in item
      else if $.isNumeric item
        count = item * 1
      else
        field = query.shift()
        count = @extractCount item[field], query
    count
  replaceString: (str) ->
    for key, value of @share
      if value? and typeof value is "string"
        rgx = new RegExp "{#{key}}", "g"
        str = str.replace rgx, value
    str
  getCoinContent: (name, urlhook) ->
    """
      <b>My #{name} Address:</b><br/>
      <br/>
      <input class="getshare-coin-address" type="text" readonly onclick="this.select();" value="{id}"/><br/>
      <a class="getshare-coin-link" href="#{urlhook}:{id}" target="_blank">
        send address to your wallet
      </a>
    """
  convertCount: (n) ->
    str = switch
      when n >= 1000000000 then (n / 1000000).toFixed(0) + "M" #1000M - *
      when n >= 10000000   then (n / 1000000).toFixed(1) + "M" #10.0M - 999.9M
      when n >= 1000000    then (n /    1000).toFixed(0) + "k" #1000k - 9999k
      when n >= 10000      then (n /    1000).toFixed(1) + "k" #10.0k - 999.9k
      else n.toFixed(0)                                        #0     - 9999
    #console.log "set #{@network.name} to #{@displayCount} from #{@count} for #{@url}"
    str
  getNetworkDefaults: (network) ->
    switch network
      when "twitter"
        button: {attr: {title: "Share on Twitter"}}
        popover:
          width: 550
          height: 330
          url: "http://twitter.com/home?status={encMessage}"
        counter:
          query:
            url: "http://urls.api.twitter.com/1/urls/count.json?url={encUrl}&callback=?"
            path: "count"
      when "twitterProfile" #Scraping - No Client JSONP API found
        button: {attr: {title: "View Profile on Twitter"}}
        popover:
          target: "_blank"
          options: false
          url: "https://twitter.com/{id}"
        counter:
          query:
            url: "http://api.getshar.es/counts/twitterProfile/{id}/?callback=?"
            path: "followers_count"
      when "facebook"
        button: {attr: {title: "Share on Facebook"}}
        popover:
          width: 550
          height: 270
          url: "http://www.facebook.com/share.php?u={encUrl}&title={encMessage}"
        counter:
          query:
            url: "https://api.facebook.com/method/fql.query?query=select%20total_count,like_count,comment_count,share_count,click_count%20from%20link_stat%20where%20url='{encUrl}'&format=json&callback=?"
            path: "total_count"
      when "pinterest"
        button: {attr: {title: "Share on Pinterest"}}
        popover:
          width: 750
          height: 350
          url: "http://pinterest.com/pin/create/bookmarklet/?media={encImageUrl}&url={encUrl}&is_video=false&description={encMessage}"
        counter:
          query:
            url: "http://api.pinterest.com/v1/urls/count.json?url={encUrl}&callback=?"
            path: "count"
      when "linkedin"
        button: {attr: {title: "Share on LinkedIn"}}
        popover:
          width: 550
          height: 450
          url: "http://www.linkedin.com/shareArticle?mini=true&url={encUrl}&title={encMessage}"
        counter:
          query:
            url: "http://www.linkedin.com/countserv/count/share?url={encUrl}&callback=?"
            path: "count"
      when "delicious"
        button: {attr: {title: "Share on Delicious"}}
        popover:
          width: 550
          height: 420
          url: "http://del.icio.us/post?url={encUrl}&title={encMessage}"
        counter:
          query:
            url: "http://feeds.delicious.com/v2/json/urlinfo/data?url={encUrl}&callback=?"
            path: "total_posts"
      when "reddit"
        button: {attr: {title: "Share on Reddit"}}
        popover:
          width: 840
          height: 800
          url: "http://www.reddit.com/submit?url={encUrl}&title={encMessage}"
        counter:
          query:
            url: "http://www.reddit.com/api/info.json?url={encUrl}&limit=100&jsonp=?"
            path: "data.children.data.score"
      when "googleplus" #Scraping - No API without API-Key
        button: {attr: {title: "Share on Google+"}}
        popover:
          width: 550
          height: 475
          url: "https://plus.google.com/share?url={encUrl}"
        counter:
          query:
            url: "http://api.getshar.es/counts/googleplus/{encUrl}/?callback=?"
            path: ""
      when "flattr" #Scraping - No Client JSONP API found
        button: {attr: {title: "Donate with Flattr"}}
        popover:
          target: "_blank"
          options: false
          url: "https://flattr.com/submit/auto?url={encUrl}&user_id={id}"
        counter:
          query:
            url: "http://api.getshar.es/counts/flattr/{encUrl}/?callback=?"
            path: ""
      when "stumbleupon" #JSON to JSONP - No API with JSONP found
        button: {attr: {title: "Share on StumbleUpon"}}
        popover:
          width: 900
          height: 500
          url: "http://www.stumbleupon.com/submit?url={encUrl}&title={encMessage}"
        counter:
          query:
            url: "http://api.getshar.es/counts/stumbleupon/{encUrl}/?callback=?"
            path: "result.views"
      when "buffer"
        button: {attr: {title: "Share on Buffer"}}
        popover:
          width: 900
          height: 500
          url: "https://bufferapp.com/add/?url={encUrl}&text={encMessage}"
        counter:
          query:
            url: "counts/buffer/{encUrl}/?callback=?"
            path: ""
      when "vk" #JSONP callback is fixed - workaround is active
        button: {attr: {title: "Share on VKontakte"}}
        popover:
          width: 550
          height: 350
          url: "http://vk.com/share.php?url={encUrl}"
        counter:
          query:
            url: "http://vk.com/share.php?act=count&index=1&url={encUrl}&format=json&callback=?"
            path: ""
      when "pocket" #Scraping - No API without Key found
        button: {attr: {title: "Save in Pocket"}}
        popover:
          width: 550
          height: 550
          url: "https://getpocket.com/save?url={encUrl}&title={encMessage}"
        counter:
          query:
            url: "http://api.getshar.es/counts/pocket/{encUrl}/?callback=?"
            path: ""
      when "weibo" #Two JSONP calls needed - Shorten URL & get count of short Url - using foreign API-Key
        button: {attr: {title: "Share on Weibo"}}
        popover:
          width: 550
          height: 450
          url: "http://tieba.baidu.com/i/app/open_share_api?link={encUrl}"
        counter:
          query:
            urlShortener: "https://api.weibo.com/2/short_url/shorten.json?source=8003029170&url_long={encUrl}&callback=?"
            url: "https://api.weibo.com/2/short_url/share/counts.json?source=8003029170&url_short={encUrl}&callback=?"
            path: "data.urls.share_counts"
      when "codepenProfile" #Scraping - No API found
        button: {attr: {title: "View Profile on CodePen"}}
        popover:
          target: "_blank"
          options: false
          url: "http://codepen.io/{id}"
        counter:
          query:
            url: "http://api.getshar.es/counts/codepenProfile/{id}/?callback=?"
            path: ""
      when "codepenPen"
        button: {attr: {title: "View Pen on CodePen"}}
        popover:
          target: "_blank"
          options: false
          url: "http://codepen.io/{id}/full/{itemId}"
        counter:
          query:
            url: "http://api.getshar.es/counts/codepenPen/{id}/{itemId}/?callback=?"
            path: ""
      when "githubProfile"
        button: {attr: {title: "View Profile on GitHub"}}
        popover:
          target: "_blank"
          options: false
          url: "https://github.com/{id}"
        counter:
          query:
            url: "http://api.getshar.es/counts/githubProfile/{id}/?callback=?"
            path: "followers"
      when "githubRepository"
        button: {attr: {title: "View Repository on GitHub"}}
        popover:
          target: "_blank"
          options: false
          url: "https://github.com/{id}/{itemId}"
        counter:
          query:
            url: "http://api.getshar.es/counts/githubRepository/{id}/{itemId}/?callback=?"
            path: "stargazers_count"
      when "dribbblePlayerLikes"
        button: {attr: {title: "View Profile on Dribbble"}}
        popover:
          target: "_blank"
          options: false
          url: "http://dribbble.com/{id}"
        counter:
          query:
            url: "http://api.dribbble.com/players/{id}?callback=?"
            path: "likes_received_count"
      when "dribbblePlayerFollowers"
        button: {attr: {title: "View Profile on Dribbble"}}
        popover:
          target: "_blank"
          options: false
          url: "http://dribbble.com/{id}"
        counter:
          query:
            url: "http://api.dribbble.com/players/{id}?callback=?"
            path: "followers_count"
      when "dribbbleShot"
        button: {attr: {title: "View Shot on Dribbble"}}
        popover:
          target: "_blank"
          options: false
          url: "http://dribbble.com/shots/{id}"
        counter:
          query:
            url: "http://api.dribbble.com/shots/{id}?callback=?"
            path: "likes_count"
      when "xing" #Scraping - No Client JSONP API found - counts with letters (eg. 2k) wont work
        button: {attr: {title: "Share on Xing"}}
        popover:
          width: 550
          height: 300
          url: "https://www.xing.com/social_plugins/share/new?url={encUrl}"
        counter:
          query:
            url: "http://api.getshar.es/counts/xing/{encUrl}/?callback=?"
            path: ""
      when "hackernews" #JSON to JSONP - No (working, keyless) API with JSONP found
        button: {attr: {title: "View on Hacker News"}}
        popover:
          target: "_blank"
          options: false
          url: "https://news.ycombinator.com/item?id={id}"
        counter:
          query:
            url: "http://api.getshar.es/counts/hackernews/{id}/?callback=?"
            path: ""
      when "bitcoin" #JSON to JSONP - No API with JSONP found
        button: {attr: {title: "Donate Bitcoin"}}
        popover: {content: @getCoinContent "Bitcoin", "bitcoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/bitcoin/{id}/?callback=?"
            path: "n_tx"
      when "litecoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate Litecoin"}}
        popover: {content: @getCoinContent "Litecoin", "litecoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/litecoin/{id}/?callback=?"
            path: ""
      when "feathercoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate Feathercoin"}}
        popover: {content: @getCoinContent "Feathercoin", "feathercoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/feathercoin/{id}/?callback=?"
            path: ""
      when "freicoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate Freicoin"}}
        popover: {content: @getCoinContent "Freicoin", "freicoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/freicoin/{id}/?callback=?"
            path: ""
      when "terracoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate Terracoin"}}
        popover: {content: @getCoinContent "Terracoin", "terracoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/terracoin/{id}/?callback=?"
            path: ""
      when "peercoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate Peercoin"}}
        popover: {content: @getCoinContent "Peercoin", "peercoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/peercoin/{id}/?callback=?"
            path: ""
      when "novacoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate Novacoin"}}
        popover: {content: @getCoinContent "Novacoin", "novacoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/novacoin/{id}/?callback=?"
            path: ""
      when "bbqcoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate BBQCoin"}}
        popover: {content: @getCoinContent "BBQCoin", "bbqcoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/bbqcoin/{id}/?callback=?"
            path: ""
      when "bytecoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate Bytecoin"}}
        popover: {content: @getCoinContent "Bytecoin", "bytecoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/bytecoin/{id}/?callback=?"
            path: ""
      when "bitbar" #Scraping - No API with JSON found
        button: {attr: {title: "Donate BitBar"}}
        popover: {content: @getCoinContent "BitBar", "bitbar"}
        counter:
          query:
            url: "http://api.getshar.es/counts/bitbar/{id}/?callback=?"
            path: ""
      when "digitalcoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate Digitalcoin"}}
        popover: {content: @getCoinContent "Digitalcoin", "digitalcoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/digitalcoin/{id}/?callback=?"
            path: ""
      when "jkcoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate JKCoin"}}
        popover: {content: @getCoinContent "JKCoin", "jkcoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/jkcoin/{id}/?callback=?"
            path: ""
      when "frankos" #Scraping - No API with JSON found
        button: {attr: {title: "Donate Frankos"}}
        popover: {content: @getCoinContent "Frankos", "frankos"}
        counter:
          query:
            url: "http://api.getshar.es/counts/frankos/{id}/?callback=?"
            path: ""
      when "goldcoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate Goldcoin"}}
        popover: {content: @getCoinContent "Goldcoin", "goldcoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/goldcoin/{id}/?callback=?"
            path: ""
      when "worldcoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate Worldcoin"}}
        popover: {content: @getCoinContent "Worldcoin", "worldcoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/worldcoin/{id}/?callback=?"
            path: ""
      when "craftcoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate CraftCoin"}}
        popover: {content: @getCoinContent "CraftCoin", "craftcoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/craftcoin/{id}/?callback=?"
            path: ""
      when "quarkcoin" #Scraping - No API with JSON found
        button: {attr: {title: "Donate QuarkCoin"}}
        popover: {content: @getCoinContent "QuarkCoin", "quarkcoin"}
        counter:
          query:
            url: "http://api.getshar.es/counts/quarkcoin/{id}/?callback=?"
            path: ""
      else {}
