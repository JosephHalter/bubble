module Sinatra
  module Bubble
    def self.registered(app)
      app.helpers Helpers
    end
    def resource(name, opts={})
      actions = [:index, :show, :create, :update, :destroy]
      actions &= opts.delete(:only) if opts.has_key? :only
      actions -= opts.delete(:except) if opts.has_key? :except
      index name, opts if actions.include? :index
      show name, opts if actions.include? :show
      create name if actions.include? :create
      update name if actions.include? :update
      destroy name if actions.include? :destroy
    end
  private
    def index(name, opts={})
      opts = find_defaults name, opts
      get "/#{name}" do
        collection = opts[:class].search(params).collect{|c| c.as_json :index}
        hash = {
          name => collection,
          :link => [{:rel => "self", :href => "#{base_url}/#{name}"}],
        }
        json hash
      end
    end
    def show(name, opts={})
    end
    def create(name, opts={})
    end
    def update(name, opts={})
    end
    def destroy(name, opts={})
    end
    def find_defaults(name, opts)
      opts[:class_name] ||= name.to_s.split("_").collect(&:capitalize).join
      opts[:class] = Object.module_eval "::#{opts[:class_name]}", __FILE__, __LINE__
      opts
    end

    module Helpers
      def base_url
        "#{request.scheme}://#{request.host_with_port}"
      end
      def json(hash)
        content_type :json
        Yajl::Encoder.encode hash
      end
    end
  end

  register Bubble
end