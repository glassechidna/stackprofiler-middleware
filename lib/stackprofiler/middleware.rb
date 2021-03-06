require 'stackprofx'
require 'rack'

module Stackprofiler
  class Middleware
    attr_accessor :ui_url

    def initialize(app, options={})
      @app = app

      pred = options[:predicate] || /profile=true/
      if pred.respond_to? :call
        @predicate = pred
      else
        regex = Regexp.new pred

        @predicate = proc do |env|
          req = Rack::Request.new env
          req.fullpath =~ regex
        end
      end

      default_opts = {mode: :wall, interval: 1000, raw: true, threads: [Thread.current]}
      @stackprof_opts = default_opts.merge(options[:stackprof] || {})
      @ui_url = options[:ui_url] || ENV['PRY_STACKPROFILER_UI_URL']
    end

    def call(env)
      if @predicate.call(env)
        out = nil
        profile = StackProfx.run(@stackprof_opts) { out = @app.call env }

        Thread.new do
          iseq = RubyVM::InstructionSequence::of @app.method(:call)
          profile[:suggested_rebase] = iseq.object_id
          profile[:name] = Rack::Request.new(env).fullpath

          url = URI::parse ui_url
          headers = {'Content-Type' => 'application/x-ruby-marshal'}
          req = Net::HTTP::Post.new(url.to_s, headers)
          req.body = Marshal.dump profile

          response = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
        end

        out
      else
        @app.call env
      end
    end
  end
end
