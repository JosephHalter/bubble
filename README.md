Bubble
======

Build scalable restful API with HATEOS and conditional requests.

Dependencies
------------

* Ruby >= 1.9.2
* optional: gem "sinatra", "~> 1.3.0.d"
* optional: gem "yajl-ruby", "~> 0.8.2"

If yajl is present, Bubble will use it to speed up json parsing and dumping. If not, Bubble will use the ruby built-in json library.

Common usage
------------

That could be your Gemfile:

    source "http://rubygems.org"
    gem "bubble"
    gem "sinatra", "~> 1.3.0.d"
    gem "yajl-ruby", "~> 0.8.2"

That could be your config.ru:

    require "bundler/setup"
    $:.unshift File.expand_path "../lib", __FILE__
    require "api"
    run Api

A basic lib/api.rb would look like that:

    require "bubble"
    require "number"
    class Api < Sinatra::Base
      register Bubble::Sinatra
      resource :number
    end

And here is an example model to put in lib/number.rb:

    class Number
      attr_accessor :value, :numberwang
      def self.search(filter)
        @@all ||= (0..99).to_a
        results = @@all.dup
        results.select!(&:odd?) if filter[:odd]=="1"
        results
      end
      def initialize(opts={})
        @value = opts[:value].to_i
      end
      def odd?
        @value.odd?
      end
      def save
      end
    end

Run it with any web server (thin, unicorn, passenger, shotgun, etc.):

    bundle exec rackup

Then you can try the following queries in terminal:

* Create

        curl --data '{"value": 1, "numberwang": false}' --header "Content-Type: application/json" http://localhost:9292/number
        curl --data '{"value": 2, "numberwang": true}' --header "Content-Type: application/json" http://localhost:9292/number
        curl --data '{"value": 3, "numberwang": false}' --header "Content-Type: application/json" http://localhost:9292/number

* Index

        curl http://localhost:9292/number

* Search

        curl http://localhost:9292/number?odd=1

* Show

        curl http://localhost:9292/number/1

* Destroy

        curl -X DELETE http://localhost:9292/number/3

* Update

        curl -X PUT --data '{"numberwang": false}' --header "Content-Type: application/json" http://localhost:9292/number/2

* Conditional request

        curl --header "ETag: "xMpCOKC5I4INzFCab3WEmw==" http://localhost:9292/number/1

* Resource not found

        curl http://localhost:9292/number/99

* Errors on create

        curl --data '{}' --header "Content-Type: application/json" http://localhost:9292/number

* Invalid serialization

        curl --data '{' --header "Content-Type: application/json" http://localhost:9292/number

Partial resources
-----------------

You can use Bubble to define a resource with only index and show and which class name doesn't match the resource name:

    class Api < Sinatra::Base
      register Bubble::Sinatra
      resource :number, :only => [:index, :show], :class_name => "CustomNumber"
    end

Mix with Sinatra
----------------

You can mix Bubble resources with other Sinatra routes:

    class Api < Sinatra::Base
      register Bubble::Sinatra
      resource :number
      get %r{urn:api:number:(.+)} do |id|
        redirect to("/number/#{id}"), 301
      end
    end

Without Sinatra
---------------

If you don't need any additional route you can also skip Sinatra and use Rack directly:

    class Api < Bubble::Rack
      resource :number
    end

Thread Safety
-------------

This gem is thread-safe.

Persistence layer
-----------------

Bubble works great with MongoDB, Redis, ActiveRecord, Sequel... You choose!

Limitations
-----------

Nested resources aren't currently in the scope of this gem. Avoiding nested resources reduces overall complexity.

Instead of:

    /number/4/winner

You can use:

    /winner?number=4

This limitation will probably be removed in a future version.

Links
-----

Documentation: http://JosephHalter.github.com/bubble/

Conclusion
----------

Because it's fully tested, you can finally concentrate on defining your models instead of wasting your time elsewhere. Now go create the restful API of your dreams.