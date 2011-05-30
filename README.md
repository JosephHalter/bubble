Bubble
======

Build scalable restful API using Sinatra, with HATEOS, conditional requests.

Dependencies
------------

* Ruby >= 1.9.2
* gem "sinatra", "~> 1.3.0.d"
* gem "yajl-ruby", "~> 0.8.2"

Usage
-----

* That could be your Gemfile:

        source "http://rubygems.org"
        gem "bubble"

* That could be your config.ru:

        $:.unshift File.expand_path "../lib", __FILE__
        require "api"
        run Api

* And a minimal lib/api.rb could look like that:

        require "bundler/setup"
        require "bubble"
        require "number"
        class Api < Bubble
          resource :number
        end

* Here an example of a model to put in lib/number.rb:

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

* Run it in any web server (thin, unicorn, passenger, shotgun, etc.):

        bundle exec rackup

* Then you can try the following queries in terminal:

  * Create

            curl --data '{"value": 1, "numberwang": false}' --header "Content-Type: application/json" http://localhost:9292/number
            curl --data '{"value": 2, "numberwang": true}' --header "Content-Type: application/json" http://localhost:9292/number
            curl --data '{"value": 3, "numberwang": false}' --header "Content-Type: application/json" http://localhost:9292/number

  * Index

            curl http://localhost:9292/number
  
  * Searches

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

Sky is the limit
================

* You can use any persistence layer, it works great with MongoDB, Redis, ActiveRecord, Sequel...

* You can use Bubble to define a resource with only index and show and which class name doesn't match the resource name:

        class Api < Bubble
          resource :number, :only => [:index, :show], :class_name => "CustomNumber"
        end

* Because it's fully tested with rspec and cucumber, you can finally concentrate on defining your models instead of wasting your time elsewhere. Now go create the restful API of your dreams.