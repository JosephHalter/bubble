module Sinatra
  module Bubble
    module Helpers
      def base_url
        self.class.base_url
      end
      def json(hash)
        content_type "application/json;charset=utf-8"
        Yajl::Encoder.encode hash
      end
      def body_params
        Yajl::Parser.parse request.body
      end
    end
    def self.registered(app)
      app.helpers Helpers
      app.before{ @@base_url = "#{request.scheme}://#{request.host_with_port}" }
    end
    def resource(name, opts={})
      actions = [:index, :show, :create, :update, :destroy]
      actions &= opts.delete(:only) if opts.has_key? :only
      actions -= opts.delete(:except) if opts.has_key? :except
      opts[:class_name] ||= name.to_s.split("_").collect(&:capitalize).join
      opts[:class] = Object.module_eval "::#{opts[:class_name]}", __FILE__, __LINE__
      create name, opts if actions.include? :create
      index name, opts if actions.include? :index
      show name, opts if actions.include? :show
      update name, opts if actions.include? :update
      destroy name, opts if actions.include? :destroy
    end
    def base_url
      @@base_url
    end
  private
    def create(name, opts)
      post "/#{name}" do
        begin
          object = opts[:class].new body_params
        rescue Yajl::ParseError
          400
        else
          if object.save
            [201, json(object.as_json :show)]
          else
            [422, json(object.as_json :new)]
          end
        end
      end
    end
    def index(name, opts)
      get "/#{name}" do
        collection = opts[:class].search(params).collect{|c| c.as_json :index}
        hash = {
          name => collection,
          :link => [{:rel => "self", :href => "#{base_url}/#{name}"}],
        }
        json hash
      end
    end
    def show(name, opts)
    end
    def update(name, opts)
    end
    def destroy(name, opts)
    end
  end

  register Bubble
end