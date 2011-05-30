module Bubble
  module Sinatra
    module Extensions
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
        get "/#{name}" do
          opts = find_defaults opts
          collection = opts[:class].search(params).collect{|c| c.as_json :index}
          output = {
            name => collection,
            :link => [
              {:rel => "self", :href => "#{base_url}/#{name}"},
            ],
          }
          render :json => output
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
      def base_url
        "#{request.scheme}://#{request.host_with_port}"
      end
      def render(hash)
        if hash[:json]
          content_type :json
          Yajl::Encoder.encode hash[:json]
        end
      end
      def find_defaults(opts)
        opts[:class_name] ||= name.to_s.split("_").collect(&:capitalize).join
        opts[:class] = opts[:class_name].constantize
        opts
      end
    end

    def self.registered(app)
      app.helpers Extensions
    end
  end
end