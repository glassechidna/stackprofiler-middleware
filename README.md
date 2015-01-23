# Stackprofiler::Middleware

Please read the [`stackprofiler`][1] gem README for background on Stackprofiler
in general.

This is a [Rack][2] middleware that makes benchmarking of Rack apps a breeze.

much more fluid experience and provide a quicker turn-around time. It does
this by passing along Pry's linebuffer to the Stackprofiler server so that
code needn't be stored in the file system for Stackprofiler to annotate.
It utilises a fork of the the brilliant [`stackprof`][3] to enable low-overhead
sampling of Ruby processes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stackprofiler-middleware'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stackprofiler-middleware

You should have also already installed the main Stackprofiler gem as well. If
you haven't done that yet, head over to that gem's repo and come back here
once you're done.

## Usage

First, boot up Stackprofiler's server in the background:

    $ stackprofiler

Using Stackprofiler at this stage is pretty simple on account of there
not yet being much flexibility in the way of configuration. This will be
fixed later - hopefully the simplicity can remain.

Once installed, add Stackprofiler's middleware somewhere in your Rack
chain, e.g.:

```ruby
config.middleware.use Stackprofiler::Middleware
```

Now start your server like normal. If you wish to profile a request,
append `profile=true` to the query string. This will inform Stackprofiler
that it should do its thing. Take note that the response will remain
unchanged - Stackprofiler will record its statistics for your later perusal
elsewhere. This is to make it easier to profile requests that don't return
visible results, e.g. XHR.

Once you have profiled a request or two, you can head over to Stackprofiler's
GUI. This is probably at [http://localhost:9292/][4]. Read
Stackprofiler's README to see how this web UI works.

### Data collection configuration

Stackprofiler's operation can be configured by passing in parameters to the
middleware specified above. While the defaults should suit most applications,
changing them is easy enough:

```ruby
config.middleware.use Stackprofiler::Middleware {
  predicate: /profile=true/, # regex form for urls to be profiled
  predicate: proc {|env| true }, # callable form for greater flexibility than regex
  stackprof: { # options to be passed directly through to stackprof, e.g.:
    interval: 1000 # sample every n micro-seconds
  }
}
```

## Contributing

1. Fork it ( https://github.com/glassechidna/stackprofiler-middleware/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[1]: https://github.com/glassechidna/stackprofiler
[2]: http://rack.github.io/
[3]: https://github.com/tmm1/stackprof
[4]: http://localhost:9292/
